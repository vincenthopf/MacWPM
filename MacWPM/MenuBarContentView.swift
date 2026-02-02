//
//  MenuBarContentView.swift
//  MacWPM
//
//  Upgraded for macOS 26 Tahoe
//

import SwiftUI
import Sparkle

struct MenuBarContentView: View {
    let tracker: WPMTracker

    var body: some View {
        Group {
            // Session Controls
            Button {
                tracker.startSession()
            } label: {
                Label("Start Session", systemImage: "play.fill")
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])

            Button {
                tracker.resetSession()
            } label: {
                Label("Reset Session", systemImage: "arrow.counterclockwise")
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])

            Button {
                tracker.endSession()
            } label: {
                Label("End Session", systemImage: "stop.fill")
            }
            .keyboardShortcut("q", modifiers: [.command, .shift])

            Divider()

            // Check for Updates
            Button("Check for Updates...") {
                tracker.updaterController.checkForUpdates(nil)
            }

            Divider()

            // Quit
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
