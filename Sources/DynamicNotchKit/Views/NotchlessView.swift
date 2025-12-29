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
            // Always render the row to maintain stable view identity during rapid transitions.
            // Use explicit height and opacity - animation applied at VStack level for smooth resize.
            compactIndicatorsRow()
                .frame(height: dynamicNotch.isHybridModeEnabled ? indicatorsRowHeight : 0)
                .opacity(dynamicNotch.isHybridModeEnabled ? 1 : 0)
                .clipped()

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
        dynamicNotch.notchSize.height - 12 // Account for top (4pt) and bottom (8pt) insets
    }

    /// Row with compact indicators and optional center content for hybrid mode.
    /// The center content is only rendered in NotchlessView (floating mode), not in NotchView.
    @ViewBuilder
    private func compactIndicatorsRow() -> some View {
        HStack(spacing: 0) {
            // Always render but hide if disabled - avoids SwiftUI conditional rendering issues
            // Use explicit frame to constrain icon size within the row
            dynamicNotch.compactLeadingContent
                .environment(\.notchSection, .compactLeading)
                .frame(width: compactIconSize, height: compactIconSize)
                .opacity(dynamicNotch.disableCompactLeading ? 0 : 1)
                .accessibilityHidden(dynamicNotch.disableCompactLeading)

            Spacer(minLength: 0)

            // Center content - visible in floating fallback, hidden by notch in notch mode
            dynamicNotch.compactCenterContent
                .environment(\.notchSection, .compactCenter)

            Spacer(minLength: 0)

            // Always render but hide if disabled - avoids SwiftUI conditional rendering issues
            // Use explicit frame to constrain icon size within the row
            dynamicNotch.compactTrailingContent
                .environment(\.notchSection, .compactTrailing)
                .frame(width: compactIconSize, height: compactIconSize)
                .opacity(dynamicNotch.disableCompactTrailing ? 0 : 1)
                .accessibilityHidden(dynamicNotch.disableCompactTrailing)
        }
        .frame(height: dynamicNotch.notchSize.height)
        .padding(.horizontal, safeAreaInset)
        .padding(.vertical, 10)
    }
}
