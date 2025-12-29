//
//  NotchView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

struct NotchView<Expanded, CompactLeading, CompactTrailing>: View where Expanded: View, CompactLeading: View, CompactTrailing: View {
    @ObservedObject private var dynamicNotch: DynamicNotch<Expanded, CompactLeading, CompactTrailing>
    @State private var compactLeadingWidth: CGFloat = 0
    @State private var compactTrailingWidth: CGFloat = 0
    private let safeAreaInset: CGFloat = 15

    init(dynamicNotch: DynamicNotch<Expanded, CompactLeading, CompactTrailing>) {
        self.dynamicNotch = dynamicNotch
    }

    private var expandedNotchCornerRadii: (top: CGFloat, bottom: CGFloat) {
        if case let .notch(topCornerRadius, bottomCornerRadius) = dynamicNotch.style {
            (top: topCornerRadius, bottom: bottomCornerRadius)
        } else {
            (top: 15, bottom: 20)
        }
    }

    private var compactNotchCornerRadii: (top: CGFloat, bottom: CGFloat) {
        (top: 6, bottom: 14)
    }

    private var minWidth: CGFloat {
        dynamicNotch.notchSize.width + (topCornerRadius * 2)
    }

    private var topCornerRadius: CGFloat {
        dynamicNotch.state == .expanded ? expandedNotchCornerRadii.top : compactNotchCornerRadii.top
    }

    private var bottomCornerRadius: CGFloat {
        dynamicNotch.state == .expanded ? expandedNotchCornerRadii.bottom : compactNotchCornerRadii.bottom
    }

    private var xOffset: CGFloat {
        if dynamicNotch.state != .compact {
            0
        } else {
            compactXOffset
        }
    }

    private var compactXOffset: CGFloat {
        (compactTrailingWidth - compactLeadingWidth) / 2
    }

    var body: some View {
        notchContent()
            .background {
                Rectangle()
                    .foregroundStyle(.black)
                    .padding(-50) // The opening/closing animation can overshoot, so this makes sure that it's still black
            }
            .mask {
                NotchShape(
                    topCornerRadius: topCornerRadius,
                    bottomCornerRadius: bottomCornerRadius
                )
                .padding(.horizontal, 0.5)
                .frame(
                    width: dynamicNotch.state != .hidden ? nil : minWidth,
                    height: dynamicNotch.state != .hidden ? nil : dynamicNotch.notchSize.height
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .offset(x: xOffset)
            .animation(.smooth, value: [compactLeadingWidth, compactTrailingWidth])
    }

    /// Builds the main notch content layout.
    ///
    /// Layout behavior:
    /// - **Normal mode**: Compact content collapses to notch width in expanded state
    /// - **Hybrid mode** (`isHybridModeEnabled`): Compact content remains visible,
    ///   filling the width of the expanded content with symmetric left/right positioning
    private func notchContent() -> some View {
        let showCompactInExpanded = dynamicNotch.isHybridModeEnabled
        let useHybridLayout = showCompactInExpanded && dynamicNotch.state == .expanded

        return ZStack(alignment: .top) {
            expandedContent()
                .fixedSize()
                .frame(
                    maxWidth: dynamicNotch.state == .expanded ? nil : 0,
                    maxHeight: dynamicNotch.state == .expanded ? nil : 0
                )
                .offset(x: dynamicNotch.state == .compact ? -compactXOffset : 0)

            compactContent()
                .fixedSize(horizontal: !useHybridLayout, vertical: true)
                .frame(maxWidth: useHybridLayout ? .infinity : nil)
                .offset(x: dynamicNotch.state == .compact ? 0 : compactXOffset)
                .frame(
                    width: (dynamicNotch.state == .compact || showCompactInExpanded) ? nil : dynamicNotch.notchSize.width,
                    height: (dynamicNotch.state == .compact && dynamicNotch.isHovering) ? dynamicNotch.menubarHeight : dynamicNotch.notchSize.height
                )
        }
        .padding(.horizontal, topCornerRadius)
        .fixedSize()
        .frame(minWidth: minWidth, minHeight: dynamicNotch.notchSize.height)
        .onHover(perform: dynamicNotch.updateHoverState)
    }

    /// Builds compact leading/trailing content.
    ///
    /// Visibility states:
    /// - **Normal mode**: Visible only in `.compact` state
    /// - **Hybrid mode**: Visible in both `.compact` and `.expanded` states
    ///
    /// Layout modes:
    /// - **Normal**: Content hugs edges with 8pt padding
    /// - **Symmetric** (hybrid + expanded): Equal-width containers centered around notch with 15pt padding
    func compactContent() -> some View {
        // In hybrid mode, show compact content in both compact AND expanded states
        // In normal mode, only show in compact state
        let showContent = dynamicNotch.isHybridModeEnabled
            ? dynamicNotch.state != .hidden
            : dynamicNotch.state == .compact

        // Symmetric layout creates equal-width containers on each side of the notch
        // This ensures compact indicators are centered within their respective halves
        let useSymmetricLayout = dynamicNotch.isHybridModeEnabled && dynamicNotch.state == .expanded

        return HStack(spacing: 0) {
            if showContent, !dynamicNotch.disableCompactLeading {
                compactSideContent(
                    content: dynamicNotch.compactLeadingContent,
                    section: .compactLeading,
                    edge: .leading,
                    scaleAnchor: .trailing,
                    useSymmetricLayout: useSymmetricLayout,
                    widthBinding: $compactLeadingWidth
                )
            }

            Spacer()
                .frame(width: dynamicNotch.notchSize.width)

            if showContent, !dynamicNotch.disableCompactTrailing {
                compactSideContent(
                    content: dynamicNotch.compactTrailingContent,
                    section: .compactTrailing,
                    edge: .trailing,
                    scaleAnchor: .leading,
                    useSymmetricLayout: useSymmetricLayout,
                    widthBinding: $compactTrailingWidth
                )
            }
        }
        .frame(height: dynamicNotch.notchSize.height)
        .onChange(of: dynamicNotch.disableCompactLeading) { _ in
            if dynamicNotch.disableCompactLeading {
                compactLeadingWidth = 0
            }
        }
        .onChange(of: dynamicNotch.disableCompactTrailing) { _ in
            if dynamicNotch.disableCompactTrailing {
                compactTrailingWidth = 0
            }
        }
    }

    func expandedContent() -> some View {
        HStack(spacing: 0) {
            if dynamicNotch.state == .expanded {
                dynamicNotch.expandedContent
                    .transition(.blur(intensity: 10).combined(with: .scale(y: 0.6, anchor: .top)).combined(with: .opacity))
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: dynamicNotch.notchSize.height) }
        .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: safeAreaInset) }
        .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
        .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
        .frame(minWidth: dynamicNotch.notchSize.width)
    }

    /// Compact icon size for the notch indicators.
    private var compactIconSize: CGFloat {
        dynamicNotch.notchSize.height - 12 // Leave visual margin within the row frame
    }

    /// Helper to build a single side (leading or trailing) of compact content.
    ///
    /// - Parameters:
    ///   - content: The view to display
    ///   - section: Environment value for the notch section
    ///   - edge: Which edge this content is on (.leading or .trailing)
    ///   - scaleAnchor: Anchor point for the scale animation
    ///   - useSymmetricLayout: Whether to use equal-width containers (hybrid expanded mode)
    ///   - widthBinding: Binding to track the content width for offset calculations
    @ViewBuilder
    private func compactSideContent(
        content: some View,
        section: DynamicNotchSection,
        edge: HorizontalEdge,
        scaleAnchor: UnitPoint,
        useSymmetricLayout: Bool,
        widthBinding: Binding<CGFloat>
    ) -> some View {
        let edgePadding: CGFloat = useSymmetricLayout ? safeAreaInset : 8
        // Apply explicit frame to ensure custom views (like gradients) have proper size
        let framedContent = content
            .environment(\.notchSection, section)
            .frame(width: compactIconSize, height: compactIconSize)

        Group {
            if useSymmetricLayout {
                // Equal-width container with content aligned to outer edge
                HStack(spacing: 0) {
                    if edge == .trailing { Spacer(minLength: 0) }
                    framedContent
                    if edge == .leading { Spacer(minLength: 0) }
                }
                .frame(maxWidth: .infinity)
            } else {
                framedContent
            }
        }
        .safeAreaInset(edge: edge, spacing: 0) { Color.clear.frame(width: edgePadding) }
        .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 4) }
        .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 8) }
        .onGeometryChange(for: CGFloat.self, of: \.size.width) { widthBinding.wrappedValue = $0 }
        .transition(.blur(intensity: 10).combined(with: .scale(x: 0, anchor: scaleAnchor)).combined(with: .opacity))
    }
}
