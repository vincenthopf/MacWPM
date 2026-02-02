//
//  MacWPMApp.swift
//  MacWPM
//
//  Created by Wilmer Terrero on 19/5/24.
//  Upgraded for macOS 26 Tahoe
//

import SwiftUI

/// App delegate to handle launch-time setup
final class AppLaunchDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let appState = AppState.shared

        // Request accessibility permission with system prompt
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            // Show our authorization window with instructions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.activate(ignoringOtherApps: true)
                // Find and show the authorize window
                for window in NSApp.windows {
                    if window.title == "Authorize MacWPM" {
                        window.makeKeyAndOrderFront(nil)
                        break
                    }
                }
            }
        } else {
            appState.tracker.setupEventMonitors()
        }
    }
}

/// Shared app state that persists across the app lifecycle
@Observable
@MainActor
final class AppState {
    static let shared = AppState()

    let tracker = WPMTracker()

    private init() {}
}

@main
struct MacWPMApp: App {
    @NSApplicationDelegateAdaptor(AppLaunchDelegate.self) var appDelegate
    private let appState = AppState.shared

    var body: some Scene {
        // Menu Bar Extra
        MenuBarExtra {
            MenuBarContentView(tracker: appState.tracker)
        } label: {
            Text("WPM: \(appState.tracker.formattedWPM)")
        }
        .menuBarExtraStyle(.menu)

        // Authorization Window
        Window("Authorize MacWPM", id: "authorize") {
            AuthorizeView(tracker: appState.tracker)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 420, height: 380)
    }
}
