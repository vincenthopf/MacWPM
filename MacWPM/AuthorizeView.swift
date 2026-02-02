//
//  AuthorizeView.swift
//  MacWPM
//
//  Created by Wilmer Terrero on 19/5/24.
//  Upgraded for macOS 26 Tahoe
//

import SwiftUI

struct AuthorizeView: View {
    let tracker: WPMTracker
    @Environment(\.dismiss) private var dismiss
    @State private var permissionCheckTimer: Timer?

    var body: some View {
        VStack(spacing: 24) {
            // App Icon
            Image("MacWPMIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .padding(.top, 20)

            // Title
            Text("Accessibility Permission Required")
                .font(.title2)
                .fontWeight(.bold)

            // Description
            Text("MacWPM needs Accessibility permission to monitor your typing speed across all apps.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            Spacer()
                .frame(height: 10)

            // Action Buttons
            actionButtons

            // Instructions
            Text("Toggle **MacWPM** in the list, then return here.")
                .font(.callout)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            // Manual check button
            Button("I've Enabled It") {
                checkAndDismiss()
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)

            Spacer()
                .frame(height: 20)
        }
        .frame(width: 400, height: 350)
        .background(.ultraThinMaterial)
        .onAppear {
            startPermissionPolling()
        }
        .onDisappear {
            stopPermissionPolling()
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if #available(macOS 26, *) {
            GlassEffectContainer {
                primaryActionButton
            }
        } else {
            primaryActionButton
        }
    }

    private var primaryActionButton: some View {
        Button {
            openAccessibilitySettings()
        } label: {
            Label("Open Accessibility Settings", systemImage: "lock.shield")
                .frame(minWidth: 200)
        }
        .conditionalGlassEffect()
        .controlSize(.large)
    }

    // MARK: - Permission Handling

    private func openAccessibilitySettings() {
        // Direct link to Accessibility pane in Privacy & Security
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    private func startPermissionPolling() {
        // Poll every 2 seconds to check if permission was granted
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            Task { @MainActor in
                if AXIsProcessTrusted() {
                    stopPermissionPolling()
                    tracker.setupEventMonitors()
                    dismiss()
                }
            }
        }
    }

    private func stopPermissionPolling() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = nil
    }

    private func checkAndDismiss() {
        if AXIsProcessTrusted() {
            tracker.setupEventMonitors()
            dismiss()
        }
    }
}

#Preview {
    AuthorizeView(tracker: WPMTracker())
}
