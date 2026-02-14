# Swift Architecture Templates

Starter templates for common Apple app architectures.

---

## Table of Contents

1. [Standard macOS App](#standard-macos-app)
2. [Document-Based macOS App](#document-based-macos-app)
3. [Menu Bar Agent](#menu-bar-agent)
4. [iOS App with Coordinators](#ios-app-with-coordinators)
5. [Cross-Platform Swift Package](#cross-platform-swift-package)
6. [Multi-Target Xcode Project](#multi-target-xcode-project)

---

## Standard macOS App

### Project Structure

```
MyMacApp/
├── MyMacApp.xcodeproj
├── Sources/
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   └── main.swift (if not using @main)
│   ├── Coordinators/
│   │   ├── AppCoordinator.swift
│   │   └── MainWindowCoordinator.swift
│   ├── Presentation/
│   │   ├── Main/
│   │   │   ├── MainViewController.swift
│   │   │   ├── MainViewModel.swift
│   │   │   └── MainWindowController.swift
│   │   └── Preferences/
│   │       ├── PreferencesViewController.swift
│   │       └── PreferencesViewModel.swift
│   ├── Services/
│   │   ├── Dependencies.swift
│   │   └── NetworkService.swift
│   ├── Repositories/
│   │   ├── DataRepository.swift
│   │   └── SettingsRepository.swift
│   └── Models/
│       └── AppModels.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── Main.storyboard (optional)
│   └── Info.plist
├── Supporting/
│   └── MyMacApp.entitlements
└── Tests/
    └── MyMacAppTests/
```

### AppDelegate.swift

```swift
import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appCoordinator: AppCoordinator?
    private let dependencies = AppDependencies()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        appCoordinator = AppCoordinator(dependencies: dependencies)
        appCoordinator?.start()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
    
    // MARK: - Menu Actions
    
    @IBAction func showPreferences(_ sender: Any?) {
        appCoordinator?.showPreferences()
    }
}
```

### Dependencies.swift

```swift
import Foundation

// MARK: - Dependencies Protocol

protocol Dependencies: AnyObject {
    var networkService: NetworkServiceProtocol { get }
    var settingsRepository: SettingsRepositoryProtocol { get }
    var dataRepository: DataRepositoryProtocol { get }
}

// MARK: - Production Dependencies

final class AppDependencies: Dependencies {
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService()
    }()
    
    lazy var settingsRepository: SettingsRepositoryProtocol = {
        UserDefaultsSettingsRepository()
    }()
    
    lazy var dataRepository: DataRepositoryProtocol = {
        CoreDataRepository(networkService: networkService)
    }()
}

// MARK: - Mock Dependencies (for testing/previews)

#if DEBUG
final class MockDependencies: Dependencies {
    var networkService: NetworkServiceProtocol = MockNetworkService()
    var settingsRepository: SettingsRepositoryProtocol = InMemorySettingsRepository()
    var dataRepository: DataRepositoryProtocol = InMemoryDataRepository()
}
#endif
```

### AppCoordinator.swift

```swift
import AppKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func start() {
        showMainWindow()
    }
    
    func showMainWindow() {
        let coordinator = MainWindowCoordinator(dependencies: dependencies, parent: self)
        addChild(coordinator)
        coordinator.start()
    }
    
    func showPreferences() {
        // Implement preferences window
    }
}
```

---

## Document-Based macOS App

### Info.plist Additions

```xml
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeName</key>
        <string>My Document</string>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>LSHandlerRank</key>
        <string>Owner</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>com.example.mydocument</string>
        </array>
        <key>NSDocumentClass</key>
        <string>$(PRODUCT_MODULE_NAME).MyDocument</string>
    </dict>
</array>

<key>UTExportedTypeDeclarations</key>
<array>
    <dict>
        <key>UTTypeConformsTo</key>
        <array>
            <string>public.data</string>
            <string>public.content</string>
        </array>
        <key>UTTypeDescription</key>
        <string>My Document</string>
        <key>UTTypeIdentifier</key>
        <string>com.example.mydocument</string>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key>
            <array>
                <string>mydoc</string>
            </array>
        </dict>
    </dict>
</array>
```

### MyDocument.swift

```swift
import AppKit
import UniformTypeIdentifiers

final class MyDocument: NSDocument {
    
    // MARK: - Data
    
    struct DocumentData: Codable {
        var title: String
        var content: String
        var metadata: Metadata
        
        struct Metadata: Codable {
            var createdAt: Date
            var modifiedAt: Date
            var version: Int
        }
    }
    
    var data: DocumentData = DocumentData(
        title: "Untitled",
        content: "",
        metadata: .init(createdAt: Date(), modifiedAt: Date(), version: 1)
    )
    
    // MARK: - NSDocument Configuration
    
    override class var autosavesInPlace: Bool { true }
    override class var autosavesDrafts: Bool { true }
    override class var preservesVersions: Bool { true }
    
    // MARK: - Window Controllers
    
    override func makeWindowControllers() {
        let dependencies = (NSApp.delegate as? AppDelegate)?.dependencies ?? AppDependencies()
        let viewModel = DocumentViewModel(document: self, dependencies: dependencies)
        let viewController = DocumentViewController(viewModel: viewModel)
        let windowController = DocumentWindowController(contentViewController: viewController)
        
        addWindowController(windowController)
    }
    
    // MARK: - Reading
    
    override func read(from data: Data, ofType typeName: String) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.data = try decoder.decode(DocumentData.self, from: data)
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        let data = try Data(contentsOf: url)
        try read(from: data, ofType: typeName)
    }
    
    // MARK: - Writing
    
    override func data(ofType typeName: String) throws -> Data {
        data.metadata.modifiedAt = Date()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        return try encoder.encode(data)
    }
    
    // MARK: - File Types
    
    override class func readableTypes() -> [String] {
        ["com.example.mydocument"]
    }
    
    override class func writableTypes(forSaveOperation saveOperation: NSDocument.SaveOperationType) -> [String] {
        ["com.example.mydocument"]
    }
    
    override class func isNativeType(_ type: String) -> Bool {
        type == "com.example.mydocument"
    }
}
```

### DocumentViewModel.swift

```swift
import Foundation
import Combine

@MainActor
final class DocumentViewModel: ObservableObject {
    
    // MARK: - Published
    
    @Published var title: String {
        didSet { document.data.title = title; markDirty() }
    }
    
    @Published var content: String {
        didSet { document.data.content = content; markDirty() }
    }
    
    @Published private(set) var lastSaved: Date?
    @Published private(set) var isDirty = false
    
    // MARK: - Private
    
    private weak var document: MyDocument?
    private let dependencies: Dependencies
    
    // MARK: - Init
    
    init(document: MyDocument, dependencies: Dependencies) {
        self.document = document
        self.dependencies = dependencies
        self.title = document.data.title
        self.content = document.data.content
        self.lastSaved = document.data.metadata.modifiedAt
    }
    
    // MARK: - Actions
    
    func save() {
        document?.save(nil)
        isDirty = false
        lastSaved = Date()
    }
    
    func revert() {
        guard let document = document else { return }
        title = document.data.title
        content = document.data.content
        isDirty = false
    }
    
    private func markDirty() {
        isDirty = true
        document?.updateChangeCount(.changeDone)
    }
}
```

---

## Menu Bar Agent

### Info.plist Configuration

```xml
<key>LSUIElement</key>
<true/>

<key>LSBackgroundOnly</key>
<false/>
```

### StatusBarController.swift

```swift
import AppKit
import Combine

final class StatusBarController {
    
    // MARK: - Properties
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var eventMonitor: Any?
    private var cancellables = Set<AnyCancellable>()
    
    private let dependencies: Dependencies
    private let viewModel: StatusViewModel
    
    // MARK: - Init
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.viewModel = StatusViewModel(dependencies: dependencies)
    }
    
    // MARK: - Setup
    
    func setup() {
        createStatusItem()
        createPopover()
        setupEventMonitor()
        setupBindings()
    }
    
    private func createStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Status")
        button.action = #selector(handleClick(_:))
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    private func createPopover() {
        let contentView = StatusPopoverView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: contentView)
        
        popover = NSPopover()
        popover?.contentViewController = hostingController
        popover?.behavior = .transient
        popover?.animates = true
    }
    
    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            self?.closePopover()
        }
    }
    
    private func setupBindings() {
        viewModel.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateStatusIcon(for: status)
            }
            .store(in: &cancellables)
    }
    
    private func updateStatusIcon(for status: ServiceStatus) {
        let imageName: String
        let color: NSColor
        
        switch status {
        case .idle:
            imageName = "circle.fill"
            color = .systemGray
        case .active:
            imageName = "circle.fill"
            color = .systemGreen
        case .error:
            imageName = "exclamationmark.circle.fill"
            color = .systemRed
        }
        
        var image = NSImage(systemSymbolName: imageName, accessibilityDescription: status.description)
        image = image?.withSymbolConfiguration(.init(paletteColors: [color]))
        statusItem?.button?.image = image
    }
    
    // MARK: - Actions
    
    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }
    
    private func togglePopover() {
        if popover?.isShown == true {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    private func showPopover() {
        guard let button = statusItem?.button else { return }
        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func closePopover() {
        popover?.performClose(nil)
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Open Dashboard", action: #selector(openDashboard), keyEquivalent: "d")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
        
        for item in menu.items {
            item.target = self
        }
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    @objc private func openDashboard() {
        // Open main window
    }
    
    @objc private func openPreferences() {
        // Open preferences
    }
    
    @objc private func quit() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Cleanup
    
    func teardown() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        statusItem = nil
    }
}
```

---

## iOS App with Coordinators

### SceneDelegate.swift

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    private let dependencies = AppDependencies()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        self.window = window
        
        appCoordinator = AppCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        appCoordinator?.start()
        
        window.makeKeyAndVisible()
        
        // Handle deep links
        handleConnectionOptions(connectionOptions)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        appCoordinator?.handleDeepLink(url)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        appCoordinator?.saveState()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        appCoordinator?.refresh()
    }
    
    private func handleConnectionOptions(_ options: UIScene.ConnectionOptions) {
        if let url = options.urlContexts.first?.url {
            appCoordinator?.handleDeepLink(url)
        }
        
        if let shortcut = options.shortcutItem {
            appCoordinator?.handleShortcut(shortcut)
        }
    }
}
```

### AppCoordinator.swift (iOS)

```swift
import UIKit

final class AppCoordinator: NavigationCoordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    private let dependencies: Dependencies
    
    init(navigationController: UINavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        if dependencies.authService.isAuthenticated {
            showMain()
        } else {
            showOnboarding()
        }
    }
    
    // MARK: - Navigation
    
    private func showOnboarding() {
        let coordinator = OnboardingCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        coordinator.onComplete = { [weak self] in
            self?.removeChild(coordinator)
            self?.showMain()
        }
        addChild(coordinator)
        coordinator.start()
    }
    
    private func showMain() {
        let coordinator = MainTabCoordinator(dependencies: dependencies)
        addChild(coordinator)
        
        navigationController.setViewControllers([coordinator.tabBarController], animated: true)
        coordinator.start()
    }
    
    // MARK: - Deep Links
    
    func handleDeepLink(_ url: URL) {
        // Parse URL and navigate
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        switch host {
        case "item":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                navigateToItem(id: id)
            }
        case "profile":
            navigateToProfile()
        default:
            break
        }
    }
    
    func handleShortcut(_ shortcut: UIApplicationShortcutItem) {
        switch shortcut.type {
        case "com.example.newitem":
            showCreateItem()
        case "com.example.search":
            showSearch()
        default:
            break
        }
    }
    
    private func navigateToItem(id: String) {
        // Navigate to specific item
    }
    
    private func navigateToProfile() {
        // Navigate to profile
    }
    
    private func showCreateItem() {
        // Show create flow
    }
    
    private func showSearch() {
        // Show search
    }
    
    // MARK: - State
    
    func saveState() {
        // Save navigation state for restoration
    }
    
    func refresh() {
        // Refresh data when coming to foreground
    }
}
```

### TabCoordinator.swift

```swift
import UIKit

final class MainTabCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let tabBarController = UITabBarController()
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func start() {
        let homeCoordinator = HomeCoordinator(
            navigationController: UINavigationController(),
            dependencies: dependencies
        )
        
        let searchCoordinator = SearchCoordinator(
            navigationController: UINavigationController(),
            dependencies: dependencies
        )
        
        let profileCoordinator = ProfileCoordinator(
            navigationController: UINavigationController(),
            dependencies: dependencies
        )
        
        // Configure tab bar items
        homeCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        searchCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: nil
        )
        
        profileCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        // Start coordinators
        addChild(homeCoordinator)
        addChild(searchCoordinator)
        addChild(profileCoordinator)
        
        homeCoordinator.start()
        searchCoordinator.start()
        profileCoordinator.start()
        
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            searchCoordinator.navigationController,
            profileCoordinator.navigationController
        ]
    }
}
```

---

## Cross-Platform Swift Package

### Package.swift

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SharedKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Core business logic - no UI dependencies
        .library(
            name: "SharedCore",
            targets: ["SharedCore"]
        ),
        // Cross-platform SwiftUI components
        .library(
            name: "SharedUI",
            targets: ["SharedUI"]
        ),
        // macOS-specific extensions
        .library(
            name: "SharedMac",
            targets: ["SharedMac"]
        ),
        // iOS-specific extensions
        .library(
            name: "SharedIOS",
            targets: ["SharedIOS"]
        ),
    ],
    dependencies: [
        // External dependencies
    ],
    targets: [
        // MARK: - Core (Platform-Agnostic)
        .target(
            name: "SharedCore",
            dependencies: [],
            path: "Sources/Core",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SharedCoreTests",
            dependencies: ["SharedCore"],
            path: "Tests/CoreTests"
        ),
        
        // MARK: - UI (SwiftUI, Cross-Platform)
        .target(
            name: "SharedUI",
            dependencies: ["SharedCore"],
            path: "Sources/UI"
        ),
        .testTarget(
            name: "SharedUITests",
            dependencies: ["SharedUI"],
            path: "Tests/UITests"
        ),
        
        // MARK: - macOS Extensions
        .target(
            name: "SharedMac",
            dependencies: ["SharedCore", "SharedUI"],
            path: "Sources/Mac"
        ),
        
        // MARK: - iOS Extensions
        .target(
            name: "SharedIOS",
            dependencies: ["SharedCore", "SharedUI"],
            path: "Sources/iOS"
        ),
    ]
)
```

### Sources/Core/Models/User.swift

```swift
import Foundation

// Pure Swift model - no platform dependencies
public struct User: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var email: String
    public var avatarURL: URL?
    public var preferences: Preferences
    public let createdAt: Date
    public var updatedAt: Date
    
    public struct Preferences: Codable, Hashable, Sendable {
        public var theme: Theme
        public var notificationsEnabled: Bool
        public var language: String
        
        public init(
            theme: Theme = .system,
            notificationsEnabled: Bool = true,
            language: String = "en"
        ) {
            self.theme = theme
            self.notificationsEnabled = notificationsEnabled
            self.language = language
        }
    }
    
    public enum Theme: String, Codable, CaseIterable, Sendable {
        case light, dark, system
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        email: String,
        avatarURL: URL? = nil,
        preferences: Preferences = Preferences(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.preferences = preferences
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

### Sources/Core/Services/UserService.swift

```swift
import Foundation

// Protocol for dependency injection
public protocol UserServiceProtocol: Sendable {
    func fetchCurrentUser() async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteAccount() async throws
}

// Implementation
public actor UserService: UserServiceProtocol {
    private let repository: UserRepositoryProtocol
    private let networkClient: NetworkClientProtocol
    
    public init(repository: UserRepositoryProtocol, networkClient: NetworkClientProtocol) {
        self.repository = repository
        self.networkClient = networkClient
    }
    
    public func fetchCurrentUser() async throws -> User {
        // Try local cache first
        if let cached = try await repository.getCachedUser() {
            return cached
        }
        
        // Fetch from network
        let user: User = try await networkClient.request(.currentUser)
        try await repository.cacheUser(user)
        return user
    }
    
    public func updateUser(_ user: User) async throws -> User {
        var updated = user
        updated.updatedAt = Date()
        
        let result: User = try await networkClient.request(.updateUser(updated))
        try await repository.cacheUser(result)
        return result
    }
    
    public func deleteAccount() async throws {
        try await networkClient.request(.deleteAccount)
        try await repository.clearCache()
    }
}
```

### Sources/UI/Components/UserAvatar.swift

```swift
import SwiftUI

// Cross-platform SwiftUI component
public struct UserAvatar: View {
    let user: User
    let size: AvatarSize
    
    public enum AvatarSize {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 48
            case .large: return 80
            }
        }
    }
    
    public init(user: User, size: AvatarSize = .medium) {
        self.user = user
        self.size = size
    }
    
    public var body: some View {
        Group {
            if let url = user.avatarURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderView
                    case .empty:
                        ProgressView()
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
    }
    
    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
            
            Text(user.name.prefix(1).uppercased())
                .font(.system(size: size.dimension * 0.4, weight: .semibold))
                .foregroundColor(.accentColor)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        UserAvatar(user: .preview, size: .small)
        UserAvatar(user: .preview, size: .medium)
        UserAvatar(user: .preview, size: .large)
    }
    .padding()
}

extension User {
    static var preview: User {
        User(name: "John Doe", email: "john@example.com")
    }
}
```

---

## Multi-Target Xcode Project

### Project Structure

```
MyMultiPlatformApp/
├── MyMultiPlatformApp.xcodeproj
├── Shared/                          # Shared code (all platforms)
│   ├── Sources/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Repositories/
│   │   └── Utilities/
│   └── Resources/
│       └── Shared.xcassets
│
├── MyAppMac/                        # macOS target
│   ├── Sources/
│   │   ├── App/
│   │   │   └── AppDelegate.swift
│   │   ├── Coordinators/
│   │   ├── Presentation/
│   │   └── Platform/                # macOS-specific implementations
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── Main.storyboard
│   └── Supporting/
│       ├── Info.plist
│       └── MyAppMac.entitlements
│
├── MyAppIOS/                        # iOS target
│   ├── Sources/
│   │   ├── App/
│   │   │   └── SceneDelegate.swift
│   │   ├── Coordinators/
│   │   ├── Presentation/
│   │   └── Platform/                # iOS-specific implementations
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   └── LaunchScreen.storyboard
│   └── Supporting/
│       ├── Info.plist
│       └── MyAppIOS.entitlements
│
├── MyAppKit/                        # Shared framework (optional)
│   ├── Sources/
│   └── MyAppKit.h
│
├── MyAppTests/                      # Shared tests
│   └── ...
│
├── MyAppMacTests/                   # macOS-specific tests
│   └── ...
│
└── MyAppIOSTests/                   # iOS-specific tests
    └── ...
```

### xcconfig Files

**Shared.xcconfig**

```xcconfig
// Common build settings for all targets

// Swift
SWIFT_VERSION = 5.9
SWIFT_STRICT_CONCURRENCY = complete

// Build
ALWAYS_SEARCH_USER_PATHS = NO
CLANG_ENABLE_MODULES = YES
ENABLE_STRICT_OBJC_MSGSEND = YES

// Code signing
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = YOUR_TEAM_ID

// Deployment
IPHONEOS_DEPLOYMENT_TARGET = 16.0
MACOSX_DEPLOYMENT_TARGET = 13.0
```

**Debug.xcconfig**

```xcconfig
#include "Shared.xcconfig"

// Debug settings
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
ENABLE_TESTABILITY = YES
GCC_OPTIMIZATION_LEVEL = 0
SWIFT_OPTIMIZATION_LEVEL = -Onone
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG
```

**Release.xcconfig**

```xcconfig
#include "Shared.xcconfig"

// Release settings
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym
ENABLE_NS_ASSERTIONS = NO
GCC_OPTIMIZATION_LEVEL = s
SWIFT_OPTIMIZATION_LEVEL = -O
SWIFT_COMPILATION_MODE = wholemodule
VALIDATE_PRODUCT = YES
```

### Conditional Code Example

```swift
// In Shared/Sources/Platform/PlatformService.swift

import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public protocol PlatformServiceProtocol {
    func openURL(_ url: URL) async -> Bool
    func copyToClipboard(_ text: String)
    var deviceModel: String { get }
}

public final class PlatformService: PlatformServiceProtocol {
    public init() {}
    
    public func openURL(_ url: URL) async -> Bool {
        #if os(macOS)
        return NSWorkspace.shared.open(url)
        #elseif os(iOS)
        return await UIApplication.shared.open(url)
        #endif
    }
    
    public func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #elseif os(iOS)
        UIPasteboard.general.string = text
        #endif
    }
    
    public var deviceModel: String {
        #if os(macOS)
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
        #elseif os(iOS)
        var systemInfo = utsname()
        uname(&systemInfo)
        return String(bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?
            .trimmingCharacters(in: .controlCharacters) ?? "Unknown"
        #else
        return "Unknown"
        #endif
    }
}
```

---

## Usage

When starting a new project:

1. Choose the appropriate template based on app type
2. Copy the structure
3. Customize Dependencies for your specific services
4. Implement coordinators for navigation
5. Build features using the ViewModel pattern
6. Test at the ViewModel layer first

For cross-platform:

1. Start with the Swift Package structure
2. Keep platform-agnostic code in `Core`
3. Use conditional compilation sparingly
4. Prefer protocol abstraction over `#if os()`
5. Test `Core` thoroughly—it's shared everywhere
