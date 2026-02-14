# Swift/AppKit Templates

Production-ready scaffolds for native Apple development.

## Available Templates

### macOS Menu Bar App
`macos-menubar-app.swift`

A complete menu bar application with:
- Status item with icon
- Popover interface
- Right-click context menu
- Tabbed preferences window
- Launch at login support

### iOS UIKit App
`ios-uikit-app.swift`

A modern iOS app using the Coordinator pattern:
- SceneDelegate setup
- Coordinator-based navigation
- MVVM view models with async/await
- DiffableDataSource collection view
- Pull-to-refresh
- Swipe-to-delete

## Usage

1. Copy the template file to your project
2. Split into separate files as marked by `// FILE:` comments
3. Create Xcode project with appropriate settings
4. Customize for your needs

## Xcode Project Setup

### macOS Menu Bar App
1. File → New → Project → macOS → App
2. Interface: Storyboard (then delete storyboard, use code-only)
3. Add `LSUIElement = YES` to Info.plist
4. Add entitlements for sandbox
5. Replace AppDelegate with template code

### iOS UIKit App
1. File → New → Project → iOS → App
2. Interface: Storyboard (then delete Main.storyboard, use SceneDelegate)
3. Remove `Main storyboard file base name` from Info.plist
4. Replace SceneDelegate with template code

## Dependencies

Templates use only Apple frameworks:
- AppKit (macOS)
- UIKit (iOS)
- Foundation
- ServiceManagement (for launch-at-login)

No third-party dependencies required.
