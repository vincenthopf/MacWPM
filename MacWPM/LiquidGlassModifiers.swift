//
//  LiquidGlassModifiers.swift
//  MacWPM
//
//  Conditional Liquid Glass styling for macOS 26+
//

import SwiftUI

extension View {
    /// Applies Liquid Glass effect on macOS 26+, falls back to borderedProminent on older versions
    @ViewBuilder
    func conditionalGlassEffect() -> some View {
        if #available(macOS 26, *) {
            self.glassEffect(.regular.interactive())
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }

    /// Applies Liquid Glass effect with tint on macOS 26+
    @ViewBuilder
    func conditionalGlassEffect(tint: Color) -> some View {
        if #available(macOS 26, *) {
            self.glassEffect(.regular.tint(tint).interactive())
        } else {
            self.buttonStyle(.borderedProminent)
                .tint(tint)
        }
    }
}

/// Container for grouping glass effects on macOS 26+
struct ConditionalGlassContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(spacing: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        if #available(macOS 26, *) {
            GlassEffectContainer(spacing: spacing) {
                content()
            }
        } else {
            VStack(spacing: spacing) {
                content()
            }
        }
    }
}
