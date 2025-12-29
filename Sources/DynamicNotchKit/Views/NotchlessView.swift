//
//  NotchlessView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

struct NotchlessView<Expanded, CompactLeading, CompactTrailing>: View where Expanded: View, CompactLeading: View, CompactTrailing: View {
    @ObservedObject private var dynamicNotch: DynamicNotch<Expanded, CompactLeading, CompactTrailing>
    @State private var windowHeight: CGFloat = 0
    private let safeAreaInset: CGFloat = 15

    init(dynamicNotch: DynamicNotch<Expanded, CompactLeading, CompactTrailing>) {
        self.dynamicNotch = dynamicNotch
    }

    private var cornerRadius: CGFloat {
        if case let .floating(cornerRadius) = dynamicNotch.style {
            cornerRadius
        } else {
            20
        }
    }

    var body: some View {
        notchContent()
            .background {
                VisualEffectView(material: .popover, blendingMode: .behindWindow)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(.quaternary, lineWidth: 1)
                    }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .padding(20)
            .onGeometryChange(for: CGFloat.self, of: \.size.height) { newHeight in
                // This makes sure that the floating window FULLY slides off before disappearing
                windowHeight = newHeight
            }
            .offset(y: dynamicNotch.state == .expanded ? dynamicNotch.notchSize.height : -windowHeight)
            .onHover(perform: dynamicNotch.updateHoverState)
    }

    /// Height of the compact indicators row including padding.
    private var indicatorsRowHeight: CGFloat {
        dynamicNotch.notchSize.height + 20 // frame height + vertical padding
    }

    private func notchContent() -> some View {
        VStack(spacing: 0) {
            // Always render the row at full size to prevent layout issues during rapid transitions.
            // Use opacity for visibility and add explicit id to maintain view identity.
            if dynamicNotch.isHybridModeEnabled {
                compactIndicatorsRow()
                    .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .top)))
            }

            dynamicNotch.expandedContent
                .transition(.blur(intensity: 10).combined(with: .opacity))
                // Only add top inset when NOT in hybrid mode (indicators row provides spacing)
                .safeAreaInset(edge: .top, spacing: 0) {
                    Color.clear
                        .frame(height: dynamicNotch.isHybridModeEnabled ? 0 : safeAreaInset)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: safeAreaInset) }
                .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
                .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
        }
        .fixedSize()
        // Apply animation at the container level so that .fixedSize() resizes smoothly
        .animation(dynamicNotch.style.conversionAnimation, value: dynamicNotch.isHybridModeEnabled)
    }

    /// Compact icon size for the floating indicators row.
    private var compactIconSize: CGFloat {
        max(dynamicNotch.notchSize.height - 12, 0) // Leave visual margin within the row frame
    }

    /// Row with compact indicators and optional center content for hybrid mode.
    /// The center content is only rendered in NotchlessView (floating mode), not in NotchView.
    @ViewBuilder
    private func compactIndicatorsRow() -> some View {
        // Use HStack spacing for automatic gaps between present elements
        HStack(spacing: 12) {
            // Conditional rendering ensures disabled views don't reserve space (matches NotchView.swift)
            if !dynamicNotch.disableCompactLeading {
                dynamicNotch.compactLeadingContent
                    .environment(\.notchSection, .compactLeading)
                    .frame(minWidth: compactIconSize, minHeight: compactIconSize, maxHeight: compactIconSize)
            }

            // Center content - visible in floating fallback, hidden by notch in notch mode
            dynamicNotch.compactCenterContent
                .environment(\.notchSection, .compactCenter)

            // Conditional rendering ensures disabled views don't reserve space (matches NotchView.swift)
            if !dynamicNotch.disableCompactTrailing {
                dynamicNotch.compactTrailingContent
                    .environment(\.notchSection, .compactTrailing)
                    .frame(minWidth: compactIconSize, minHeight: compactIconSize, maxHeight: compactIconSize)
            }
        }
        .frame(height: dynamicNotch.notchSize.height)
        .padding(.horizontal, safeAreaInset)
        .padding(.vertical, 10)
    }
}
