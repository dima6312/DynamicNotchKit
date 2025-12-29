@testable import DynamicNotchKit
import SwiftUI
import Testing

extension Tag {
    @Tag static var notchStyle: Self
    @Tag static var floatingStyle: Self
}

/// Hey there! Looks like you found DynamicNotchKit's tests.
/// Please note that these tests do NOT actually "test" anything. They are only here to serve as examples of usage of DynamicNotchKit.
/// To run these tests, simply `cd` into the `DynamicNotchKit` directory and run `swift test`. Alternatively, open this package directly in Xcode, and the tests should show up in the sidebar.
@MainActor
@Suite(.serialized)
struct DynamicNotchKitTests {
    // MARK: - DynamicNotchInfo - Simple

    @Test("Info - Simple notch style", .tags(.notchStyle))
    func dynamicNotchInfoSimpleNotchStyle() async throws {
        try await _dynamicNotchInfoSimple(with: .notch)
    }

    @Test("Info - Simple floating style", .tags(.floatingStyle))
    func dynamicNotchInfoSimpleFloatingStyle() async throws {
        try await _dynamicNotchInfoSimple(with: .floating)
    }

    func _dynamicNotchInfoSimple(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotchInfo(
            icon: .init(systemName: "info.circle"),
            title: "This is `DynamicNotchInfo`",
            description: "It provides preset styles for easy use.",
            style: style
        )

        await notch.expand()

        try await Task.sleep(for: .seconds(4))

        withAnimation {
            notch.icon = .init(systemName: "arrow.trianglehead.2.clockwise")
            notch.title = "Content can be updated as well!"
            notch.description = "It's that simple!"
        }

        try await Task.sleep(for: .seconds(4))

        await notch.hide()
    }

    // MARK: - DynamicNotchInfo - Advanced

    @Test("Info - Advanced notch style", .tags(.notchStyle))
    func dynamicNotchInfoAdvancedNotchStyle() async throws {
        try await _dynamicNotchInfoAdvanced(with: .notch)
    }

    @Test("Info - Advanced floating style", .tags(.floatingStyle))
    func dynamicNotchInfoAdvancedFloatingStyle() async throws {
        try await _dynamicNotchInfoAdvanced(with: .floating)
    }

    func _dynamicNotchInfoAdvanced(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotchInfo(
            icon: .init(systemName: "info.circle"),
            title: "`DynamicNotchInfo`: advanced usage",
            description: "More than just images!",
            style: style
        )

        await notch.expand()

        try await Task.sleep(for: .seconds(4))

        withAnimation {
            notch.icon = .init(progress: .constant(0.5))
            notch.title = "Like progress bars..."
            notch.description = nil
        }

        try await Task.sleep(for: .seconds(4))

        withAnimation {
            notch.icon = nil
            notch.title = "There's also a compact style like iOS!"
            notch.description = "Note: this doesn't work in the floating style."
        }

        try await Task.sleep(for: .seconds(4))

        withAnimation {
            notch.compactLeading = .init(systemName: "moon.fill", color: .blue)
        }
        await notch.compact()

        try await Task.sleep(for: .seconds(2))

        withAnimation {
            notch.compactTrailing = .init(systemName: "eyes.inverse", color: .orange)
        }

        try await Task.sleep(for: .seconds(2))

        withAnimation {
            notch.compactLeading = nil
        }

        try await Task.sleep(for: .seconds(2))

        await notch.hide()
    }

    // MARK: - DynamicNotchInfo - Custom

    @Test("Info - Custom notch style & gradient", .tags(.notchStyle))
    func dynamicNotchInfoCustomNotchStyle() async throws {
        try await _dynamicNotchInfoGradientCustomRadii(with: .notch(topCornerRadius: 10, bottomCornerRadius: 25))
    }

    @Test("Info - Custom floating style & gradient", .tags(.floatingStyle), .disabled("Compact mode does not support floating windows"))
    func dynamicNotchInfoCustomFloatingStyle() async throws {
        try await _dynamicNotchInfoGradientCustomRadii(with: .floating(cornerRadius: 25))
    }

    func _dynamicNotchInfoGradientCustomRadii(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotchInfo(
            icon: .init {
                LinearGradient(
                    colors: [.blue, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(.rect(cornerRadius: 4))
                .aspectRatio(contentMode: .fit)
            },
            title: "This a gradient!",
            description: "It ships with a `matchedGeometryEffect` for easy animations.",
            style: style
        )

        await notch.expand()
        try await Task.sleep(for: .seconds(4))
        await notch.compact()
        try await Task.sleep(for: .seconds(2))
        await notch.expand()
        try await Task.sleep(for: .seconds(2))
        await notch.compact()
        try await Task.sleep(for: .seconds(2))
        await notch.hide()
    }

    // MARK: DynamicNotchInfo - App Icon

    @Test("Info - Notch with custom icon", .tags(.notchStyle))
    func dynamicNotchInfoAppIcon() async throws {
        try await _testInfoWithAppIcon(with: .notch)
    }

    @Test("Info - Floating with custom icon", .tags(.floatingStyle), .disabled("Compact mode does not support floating windows"))
    func dynamicNotchInfoAppIconFloating() async throws {
        try await _testInfoWithAppIcon(with: .floating)
    }

    func _testInfoWithAppIcon(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotchInfo(
            icon: .init(image: Image(nsImage: NSImage(named: NSImage.applicationIconName)!)),
            title: "We support custom icons as well!",
            description: "As always, with a provided `matchedGeometryEffect`.",
            compactTrailing: .init(systemName: "square.and.arrow.up", color: .blue),
            style: style
        )

        await notch.expand()
        try await Task.sleep(for: .seconds(4))
        await notch.compact()
        try await Task.sleep(for: .seconds(1))
        withAnimation {
            notch.compactTrailing = .init(progress: .constant(1.0), color: .blue)
        }
        try await Task.sleep(for: .seconds(2))
        await notch.hide()
    }

    @Test("Info - Notch with changing compact icons", .tags(.notchStyle))
    func dynamicNotchInfoCompactIcons() async throws {
        try await _testDifferentCompactIcons(with: .notch)
    }

    func _testDifferentCompactIcons(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotchInfo(
            icon: .init(systemName: "info.circle"),
            title: "Compact icons can change!",
            description: "This will show some combos.",
            compactLeading: .init(systemName: "moon.fill", color: .blue),
            compactTrailing: .init(systemName: "eyes.inverse", color: .orange),
            style: style
        )

        await notch.expand()
        try await Task.sleep(for: .seconds(4))
        await notch.compact()
        try await Task.sleep(for: .seconds(2))
        withAnimation {
            notch.compactLeading = .init(systemName: "arrow.triangle.2.circlepath", color: .teal)
        }
        try await Task.sleep(for: .seconds(2))
        withAnimation {
            notch.compactTrailing = .init(progress: .constant(0.75))
        }
        try await Task.sleep(for: .seconds(2))
        withAnimation {
            notch.compactLeading = .init(systemName: "scribble.variable", color: .indigo)
        }
        try await Task.sleep(for: .seconds(2))
        withAnimation {
            notch.compactTrailing = .init(systemName: "rectangle.pattern.checkered", color: .yellow)
        }
        try await Task.sleep(for: .seconds(2))
        withAnimation {
            notch.compactLeading = .init(image: Image(nsImage: NSImage(named: NSImage.applicationIconName)!))
        }
        try await Task.sleep(for: .seconds(2))
        await notch.hide()
    }

    @Test("DynamicNotch - Usage showcase - Notch style", .tags(.notchStyle))
    func dynamicNotchShowcaseNotchStyle() async throws {
        try await _dynamicNotchShowcase(with: .notch)
    }

    @Test("DynamicNotch - Usage showcase - Floating style", .tags(.floatingStyle))
    func dynamicNotchShowcaseFloatingStyle() async throws {
        try await _dynamicNotchShowcase(with: .floating)
    }

    func _dynamicNotchShowcase(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotch(style: style) {
            VStack(spacing: 10) {
                ForEach(0 ..< 10) { i in
                    Text("Hello World \(i)")
                }
            }
        } compactLeading: {
            Image(systemName: "moon.fill")
                .foregroundStyle(.blue)
        } compactTrailing: {
            Capsule()
                .frame(width: 8)
                .foregroundStyle(.white)
        }

        await notch.expand()
        try await Task.sleep(for: .seconds(2))
        await notch.compact()
        try await Task.sleep(for: .seconds(2))
        await notch.hide()
    }

    @Test("DynamicNotch - Rapid Fire", .tags(.notchStyle))
    func dynamicNotchRapidFire() async throws {
        for i in 0 ..< 30 {
            let notch = DynamicNotchInfo(
                icon: .init(systemName: "gauge.with.dots.needle.100percent"),
                title: "Rapid Fire Test \(i + 1)"
            )

            await notch.expand()
            await notch.hide()
        }
    }

    // MARK: - Hybrid Mode (Compact Content in Expanded State)

    @Test("DynamicNotch - Hybrid mode with compact indicators (notch style)", .tags(.notchStyle))
    func dynamicNotchHybridModeNotchStyle() async throws {
        try await _dynamicNotchHybridMode(with: .notch)
    }

    @Test("DynamicNotch - Hybrid mode with floating style (explicit)", .tags(.floatingStyle))
    func dynamicNotchHybridModeFloatingStyle() async throws {
        // Test explicit hybrid mode on floating style
        try await _dynamicNotchHybridMode(with: .floating)
    }

    func _dynamicNotchHybridMode(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotch(
            style: style,
            showCompactContentInExpandedMode: true
        ) {
            VStack(spacing: 8) {
                Text("Hybrid Layout Demo")
                    .font(.headline)
                Text("Compact indicators remain visible alongside expanded content.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } compactLeading: {
            Image(systemName: "waveform")
                .foregroundStyle(.green)
        } compactTrailing: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        }

        // Set center content for floating mode (visible between leading/trailing icons)
        notch.compactCenterContent = AnyView(
            Text("Hybrid Mode")
                .font(.caption)
                .foregroundStyle(.secondary)
        )

        // Verify initial state
        #expect(notch.showCompactContentInExpandedMode == true, "User setting should be true")
        #expect(notch.isHybridModeEnabled == true, "Hybrid mode should be enabled via user setting")

        await notch.expand()
        #expect(notch.state == .expanded, "State should be expanded after expand()")
        #expect(notch.isHybridModeEnabled == true, "Hybrid mode should remain enabled in expanded state")
        try await Task.sleep(for: .seconds(2))

        // Transition to compact - behavior differs by style
        await notch.compact()
        if style.isFloating {
            // Floating style stays expanded with hybrid mode
            #expect(notch.state == .expanded, "Floating style should stay expanded after compact()")
            #expect(notch.isHybridModeEnabled == true, "Hybrid mode should be enabled")
        } else {
            // Notch style goes to actual compact state
            #expect(notch.state == .compact, "Notch style should be in compact state")
            #expect(notch.isHybridModeEnabled == true, "Hybrid mode should still be enabled from user setting")
        }
        try await Task.sleep(for: .seconds(2))

        await notch.hide()
        #expect(notch.state == .hidden, "State should be hidden after hide()")
    }

    // MARK: - Floating Fallback (compact() auto-enables hybrid mode)

    @Test("DynamicNotch - Floating fallback: compact() enables hybrid mode", .tags(.floatingStyle))
    func dynamicNotchFloatingFallback() async throws {
        // When compact() is called on floating style, it should auto-enable hybrid mode
        // and expand (not hide), showing compact indicators alongside expanded content.
        // This provides consistent UX across notch and non-notch Macs.
        let notch = DynamicNotch(
            style: .floating
            // Note: showCompactContentInExpandedMode is NOT set (defaults to false)
        ) {
            VStack(spacing: 8) {
                Text("Floating Fallback Test")
                    .font(.headline)
                Text("Compact indicators should appear after calling compact()")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } compactLeading: {
            Image(systemName: "waveform")
                .foregroundStyle(.green)
        } compactTrailing: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        }

        // Set center content for floating fallback (visible between leading/trailing icons)
        notch.compactCenterContent = AnyView(
            Text("Fallback Mode")
                .font(.caption)
                .foregroundStyle(.secondary)
        )

        // Verify initial state - user setting is false, internal flag is false
        #expect(notch.showCompactContentInExpandedMode == false, "User setting should default to false")
        #expect(notch.floatingHybridModeActive == false, "Internal flag should start as false")
        #expect(notch.isHybridModeEnabled == false, "Hybrid mode should not be enabled initially")

        // Start expanded (no hybrid mode yet)
        await notch.expand()
        #expect(notch.state == .expanded, "State should be expanded after expand()")
        #expect(notch.isHybridModeEnabled == false, "Hybrid mode should not be enabled after expand()")
        try await Task.sleep(for: .seconds(2))

        // Call compact() - on floating, this should:
        // 1. NOT hide the window (state stays expanded)
        // 2. Auto-enable hybrid mode via internal flag
        // 3. Show compact indicators alongside expanded content
        await notch.compact()
        #expect(notch.state == .expanded, "State should remain expanded, NOT switch to compact or hidden")
        #expect(notch.floatingHybridModeActive == true, "Internal hybrid flag should be set")
        #expect(notch.showCompactContentInExpandedMode == false, "User property should NOT be mutated")
        #expect(notch.isHybridModeEnabled == true, "Hybrid mode should be enabled via internal flag")
        try await Task.sleep(for: .seconds(2))

        await notch.hide()
        #expect(notch.state == .hidden, "State should be hidden after hide()")
        // Note: floatingHybridModeActive is reset AFTER animation completes in closePanelTask
        try await Task.sleep(for: .seconds(0.5)) // Wait for animation to complete
        #expect(notch.floatingHybridModeActive == false, "Internal flag should reset after hide()")
    }

    // MARK: - Hybrid Mode Reset Tests

    @Test("DynamicNotch - floatingHybridModeActive resets on explicit expand()", .tags(.floatingStyle))
    func dynamicNotchHybridModeResetOnExpand() async throws {
        let notch = DynamicNotch(style: .floating) {
            Text("Test")
        } compactLeading: {
            Image(systemName: "circle")
        } compactTrailing: {
            Image(systemName: "square")
        }

        // Enable hybrid mode via compact()
        await notch.expand()
        await notch.compact()
        #expect(notch.floatingHybridModeActive == true, "Hybrid mode should be active after compact()")
        #expect(notch.isHybridModeEnabled == true)

        // Calling expand() should reset the flag
        await notch.expand()
        #expect(notch.floatingHybridModeActive == false, "Hybrid mode should reset on explicit expand()")
        #expect(notch.isHybridModeEnabled == false, "Hybrid mode should be disabled")

        await notch.hide()
    }

    @Test("DynamicNotch - isHybridModeEnabled computed property logic", .tags(.notchStyle))
    func dynamicNotchHybridModeComputedProperty() async throws {
        // Test with user setting = true
        let notch1 = DynamicNotch(
            style: .notch,
            showCompactContentInExpandedMode: true
        ) { Text("Test") }
        #expect(notch1.isHybridModeEnabled == true, "Should be enabled via user setting")

        // Test with user setting = false (default)
        let notch2 = DynamicNotch(style: .floating) {
            Text("Test")
        } compactLeading: {
            Image(systemName: "circle")
        }
        #expect(notch2.isHybridModeEnabled == false, "Should be disabled by default")

        // Enable via floating fallback
        await notch2.expand()
        await notch2.compact()
        #expect(notch2.isHybridModeEnabled == true, "Should be enabled via internal flag")
        #expect(notch2.showCompactContentInExpandedMode == false, "User setting should remain false")

        await notch2.hide()
    }

    @Test("DynamicNotch - Floating fallback from hidden state", .tags(.floatingStyle))
    func dynamicNotchFloatingFallbackFromHidden() async throws {
        // Tests that compact() called directly from hidden state correctly enables hybrid mode.
        // This verifies the fix for the bug where floatingHybridModeActive was reset in _expand()
        // before the guard check, breaking the floating fallback when compact() is called from .hidden state.
        let notch = DynamicNotch(style: .floating) {
            Text("Test")
        } compactLeading: {
            Image(systemName: "circle")
        } compactTrailing: {
            Image(systemName: "square")
        }

        // Verify initial hidden state
        #expect(notch.state == .hidden)
        #expect(notch.floatingHybridModeActive == false)

        // Call compact() directly from hidden state (without calling expand() first)
        await notch.compact()
        try await Task.sleep(for: .seconds(0.5))

        // Should auto-expand with hybrid mode enabled
        #expect(notch.state == .expanded, "Should expand from hidden state")
        #expect(notch.floatingHybridModeActive == true, "Hybrid mode should be active")
        #expect(notch.isHybridModeEnabled == true)

        await notch.hide()
    }

    @Test("DynamicNotch - Rapid state transitions don't crash", .tags(.floatingStyle))
    func dynamicNotchRapidStateTransitions() async throws {
        let notch = DynamicNotch(style: .floating) {
            Text("Rapid Test")
        } compactLeading: {
            Image(systemName: "circle")
        } compactTrailing: {
            Image(systemName: "square")
        }

        // Rapid fire state changes - should complete without crashes
        for _ in 0 ..< 5 {
            await notch.expand()
            await notch.compact()
            await notch.expand()
            await notch.hide()
        }

        #expect(notch.state == .hidden, "Should end in hidden state")
    }
}
