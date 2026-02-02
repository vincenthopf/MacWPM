# MacWPM

![MacWPM](banner.png)

MacWPM is a macOS menubar app that displays the current words per minute (WPM) of the user. It is designed to be used while typing to help users improve their typing speed.

## macOS 26 Tahoe Upgrade (In Progress)

This fork is being upgraded to support **macOS 26 Tahoe** with the new Liquid Glass design system and modern SwiftUI patterns.

### Changes Made

| Component | Before | After |
|-----------|--------|-------|
| Deployment Target | macOS 13.1 | macOS 14.0+ |
| Menu Bar | NSStatusItem + NSMenu | SwiftUI MenuBarExtra |
| Architecture | AppDelegate-based | @Observable + SwiftUI App lifecycle |
| UI Styling | Standard AppKit | Conditional Liquid Glass (macOS 26+) |
| Sparkle | 2.6.2 | 2.8.1 (Tahoe compatible) |
| Version | 1.0.3 | 2.0.0 |

### New Files

- `WPMTracker.swift` - @Observable model for WPM tracking with keyboard event monitoring
- `MenuBarContentView.swift` - SwiftUI menu content for MenuBarExtra
- `LiquidGlassModifiers.swift` - Conditional Liquid Glass styling extensions

### Deleted Files

- `AppDelegate.swift` - Logic moved to WPMTracker and MacWPMApp

### Improved Accessibility Permission Flow

- Single "Open Accessibility Settings" button (replaces 4 confusing buttons)
- Auto-detection when permission is granted (polls every 2 seconds)
- System permission prompt triggered on launch

### Known Issues (WIP)

- [ ] Event monitoring setup needs verification after permission grant
- [ ] Testing required on macOS 26 for Liquid Glass effects

---

## Usage

1. Run the app
2. Grant Accessibility permission when prompted
3. Click the WPM counter in the menu bar
4. Click "Start Session"
5. Start typing - WPM updates in real-time

## Distribution

### Build and Notarize

To build and notarize the app, run the following command in the root directory of the project:

```bash
fastlane macos notarized
```

### Generate appcast.xml

Run generate_appcast tool from Sparkle's distribution archive specifying the path to the folder with update archives. Allow it to access the Keychain if it asks for it (it's needed to generate signatures in the appcast).

```bash
./bin/generate_appcast /path/to/your/updates_folder/
```

## Requirements

- macOS 14.0+ (Sonoma or later)
- Accessibility permission required for keyboard monitoring
- Enhanced Liquid Glass UI on macOS 26 Tahoe
