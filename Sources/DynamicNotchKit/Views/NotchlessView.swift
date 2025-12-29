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

    private func notchContent() -> some View {
        VStack(spacing: 0) {
            // Show compact indicators row in hybrid mode
            if dynamicNotch.isHybridModeEnabled {
                compactIndicatorsRow()
            }

            dynamicNotch.expandedContent
                .transition(.blur(intensity: 10).combined(with: .opacity))
                // Only add top inset when NOT in hybrid mode (indicators row provides spacing)
                .safeAreaInset(edge: .top, spacing: 0) {
                    Color.clear.frame(height: dynamicNotch.isHybridModeEnabled ? 0 : safeAreaInset)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: safeAreaInset) }
                .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
                .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
        }
        .fixedSize()
    }

    /// Row with compact indicators and optional center content for hybrid mode.
    /// The center content is only visible in floating mode (hidden by notch in notch mode).
    @ViewBuilder
    private func compactIndicatorsRow() -> some View {
        HStack(spacing: 0) {
            // Always render but hide if disabled - avoids SwiftUI conditional rendering issues
            dynamicNotch.compactLeadingContent
                .environment(\.notchSection, .compactLeading)
                .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 4) }
                .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 8) }
                .opacity(dynamicNotch.disableCompactLeading ? 0 : 1)

            Spacer()

            // Center content - visible in floating fallback, hidden by notch in notch mode
            dynamicNotch.compactCenterContent
                .environment(\.notchSection, .compactCenter)

            Spacer()

            // Always render but hide if disabled - avoids SwiftUI conditional rendering issues
            dynamicNotch.compactTrailingContent
                .environment(\.notchSection, .compactTrailing)
                .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 4) }
                .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 8) }
                .opacity(dynamicNotch.disableCompactTrailing ? 0 : 1)
        }
        .frame(height: dynamicNotch.notchSize.height)
        .padding(.horizontal, safeAreaInset)
        .padding(.vertical, 10)
        .transition(.blur(intensity: 10).combined(with: .opacity))
    }
}
