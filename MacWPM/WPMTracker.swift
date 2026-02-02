//
//  WPMTracker.swift
//  MacWPM
//
//  Upgraded for macOS 26 Tahoe
//

import SwiftUI
import Sparkle
import os.log

private let logger = Logger(subsystem: "com.wilmerterrero.MacWPM", category: "wpmtracker")

/// Key codes for excluded keys (delete, backspace)
private enum ExcludedKeyCode: UInt16 {
    case delete = 51
    case forwardDelete = 117
}

@Observable
@MainActor
final class WPMTracker {
    // MARK: - Published State

    private(set) var formattedWPM: String = "0.00"
    private(set) var isSessionStarted: Bool = false

    var needsAccessibilityPermission: Bool {
        !AXIsProcessTrusted()
    }

    // MARK: - Private State

    private var startTime: Date?
    private var resetTimer: Timer?
    private var keystrokeCount: Int = 0
    private var totalKeystrokes: Int = 0
    private var totalTime: TimeInterval = 0

    private var keyDownEventMonitor: Any?
    private var keyUpEventMonitor: Any?

    // MARK: - Sparkle Updater

    let updaterController: SPUStandardUpdaterController

    // MARK: - Initialization

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    // Note: No deinit cleanup needed - app uses singleton pattern and
    // event monitors are cleaned up when the app terminates

    // MARK: - Setup

    func setupEventMonitors() {
        guard AXIsProcessTrusted() else {
            logger.warning("Accessibility not enabled - cannot setup event monitors")
            return
        }

        // Remove any existing monitors first
        if let monitor = keyDownEventMonitor {
            NSEvent.removeMonitor(monitor)
            keyDownEventMonitor = nil
        }
        if let monitor = keyUpEventMonitor {
            NSEvent.removeMonitor(monitor)
            keyUpEventMonitor = nil
        }

        keyDownEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            Task { @MainActor in
                self?.handleKeyEvent(event)
            }
        }

        // Note: We only need keyDown for WPM tracking, keyUp was redundant
        logger.info("Event monitors setup successfully - accessibility granted")
    }

    // MARK: - Event Handling

    private func handleKeyEvent(_ event: NSEvent) {
        guard isSessionStarted else {
            logger.debug("Key event ignored - session not started")
            return
        }

        // Reset inactivity timer
        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.endSession()
            }
        }

        if startTime == nil {
            startTime = Date()
        }

        // Exclude modifier keys and delete/backspace keys
        let excludedKeys: [UInt16] = [
            ExcludedKeyCode.delete.rawValue,
            ExcludedKeyCode.forwardDelete.rawValue
        ]
        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if !excludedKeys.contains(event.keyCode) && modifierFlags.isEmpty {
            keystrokeCount += 1
            logger.debug("Keystroke counted: \(self.keystrokeCount)")
        }

        updateWPM()
    }

    private func updateWPM() {
        guard let startTime = startTime else { return }

        let timeInterval = Date().timeIntervalSince(startTime)
        let minutes = timeInterval / 60.0

        guard minutes > 0 else {
            formattedWPM = "0.00"
            return
        }

        let wpm = Double(keystrokeCount / 5) / minutes
        let overallWPM = wpm / 10

        formattedWPM = String(format: "%.2f", overallWPM)
    }

    // MARK: - Session Control

    func startSession() {
        isSessionStarted = true
        startTime = Date()
        keystrokeCount = 0
        formattedWPM = "0.00"
        logger.info("Session started")
    }

    func resetSession() {
        invalidateTimer()
        startTime = nil
        isSessionStarted = false
        keystrokeCount = 0
        formattedWPM = "0.00"
        logger.info("Session reset")
    }

    func endSession() {
        invalidateTimer()

        if let startTime = startTime {
            let timeInterval = Date().timeIntervalSince(startTime)
            totalKeystrokes += keystrokeCount
            totalTime += timeInterval
        }

        startTime = nil
        keystrokeCount = 0
        isSessionStarted = false
        logger.info("Session ended")
    }

    private func invalidateTimer() {
        resetTimer?.invalidate()
        resetTimer = nil
    }
}
