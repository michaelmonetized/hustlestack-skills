# Swift/AppKit Coding Standards

Comprehensive coding standards for native Apple development with AppKit (macOS) and UIKit (iOS).

## File Organization

### File Header

No boilerplate headers. Apple-style headers with dates and copyright add noise. The Git history provides provenance.

```swift
// ❌ Don't do this
//
//  MainViewController.swift
//  MyApp
//
//  Created by Developer on 2/14/26.
//  Copyright © 2026 Company. All rights reserved.
//

// ✅ Just start with imports
import AppKit
```

### Import Order

```swift
// 1. Framework imports (alphabetical)
import AppKit
import Foundation

// 2. System frameworks
import CoreData
import Security
import UniformTypeIdentifiers

// 3. Third-party (alphabetical)
import Alamofire  // (avoid if possible — prefer URLSession)

// 4. Internal modules
@testable import MyAppCore  // Tests only
```

### File Structure

```swift
import AppKit

// MARK: - Protocol Definitions (if file-local)

protocol SomeDelegate: AnyObject {
    func didComplete()
}

// MARK: - Main Type

final class MyViewController: NSViewController {
    
    // MARK: - Types (nested enums, structs)
    
    enum Section {
        case main
        case details
    }
    
    // MARK: - Properties (in order)
    
    // 1. Static/class properties
    static let reuseIdentifier = "MyCell"
    
    // 2. IBOutlets (if using Interface Builder)
    @IBOutlet private weak var tableView: NSTableView!
    
    // 3. Public/internal stored properties
    weak var delegate: SomeDelegate?
    var items: [Item] = []
    
    // 4. Private stored properties
    private let viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // 5. Computed properties
    var isEmpty: Bool {
        items.isEmpty
    }
    
    // 6. Lazy properties
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // MARK: - Initialization
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        bindViewModel()
    }
    
    // MARK: - Setup
    
    private func setupViews() { }
    private func setupConstraints() { }
    private func bindViewModel() { }
    
    // MARK: - Actions
    
    @objc private func buttonTapped(_ sender: NSButton) { }
    
    // MARK: - Private Methods
    
    private func updateUI() { }
}

// MARK: - Protocol Conformances (each in separate extension)

extension MyViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        items.count
    }
}

extension MyViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        nil
    }
}
```

## Naming Conventions

### Types

```swift
// ✅ Types: PascalCase
class UserProfileViewController: NSViewController { }
struct NetworkConfiguration { }
enum LoadingState { }
protocol DataSourceProviding { }

// ✅ Protocols: -ing, -able, or noun describing capability
protocol Loadable { }
protocol DataProviding { }
protocol TableViewDataSource { }  // When wrapping Apple protocol
```

### Properties & Methods

```swift
// ✅ Properties and methods: camelCase
let userName: String
var isLoading: Bool
func fetchUserProfile() async throws -> User

// ✅ Boolean properties: is, has, should, can
var isEmpty: Bool
var hasUnsavedChanges: Bool
var shouldAutoSave: Bool
var canDelete: Bool

// ✅ Factory methods: make prefix
func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item>
func makeConfiguration() -> NSCollectionLayoutSection

// ✅ Setup methods: setup prefix (not configure)
private func setupViews()
private func setupConstraints()
private func setupNotifications()
```

### Constants

```swift
// ✅ Static constants in enum namespace
enum Layout {
    static let padding: CGFloat = 16
    static let cornerRadius: CGFloat = 8
    static let animationDuration: TimeInterval = 0.3
}

// ✅ Notification names
extension Notification.Name {
    static let userDidLogIn = Notification.Name("userDidLogIn")
    static let dataDidUpdate = Notification.Name("dataDidUpdate")
}

// ✅ UserDefaults keys
enum UserDefaultsKey {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let lastSyncDate = "lastSyncDate"
}
```

### File Naming

```
// View Controllers
MainViewController.swift
SettingsViewController.swift

// Window Controllers (macOS)
MainWindowController.swift
PreferencesWindowController.swift

// Views
ProfileHeaderView.swift
ItemCollectionViewCell.swift

// View Models
MainViewModel.swift
SettingsViewModel.swift

// Models
User.swift
Item.swift

// Services
NetworkService.swift
PersistenceService.swift

// Protocols (in their own file or with primary implementation)
DataProviding.swift          // Just protocol
NetworkService.swift         // Protocol + implementation

// Extensions
String+Validation.swift
NSView+Layout.swift
```

## Swift Style

### Type Inference

```swift
// ✅ Use type inference when type is obvious
let message = "Hello"
let count = 42
let items = [Item]()
let dict = [String: Int]()

// ✅ Explicit types when not obvious or for documentation
let timeout: TimeInterval = 30
let statusCode: Int = response.statusCode
let items: [Item] = try decoder.decode([Item].self, from: data)
```

### Optionals

```swift
// ✅ Guard for early exit
func process(item: Item?) {
    guard let item = item else { return }
    // Use item
}

// ✅ Guard with multiple conditions
guard 
    let data = response.data,
    let user = try? decoder.decode(User.self, from: data),
    user.isActive
else {
    return
}

// ✅ if let for conditional logic (no else needed)
if let error = error {
    showError(error)
}

// ✅ Optional chaining
user?.profile?.avatar?.url

// ✅ Nil coalescing for defaults
let name = user?.name ?? "Unknown"

// ❌ Avoid force unwrapping except in tests/obvious cases
let value = optional!  // Crash if nil

// ✅ Force unwrap only when failure is programmer error
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!  // Registered in setup
```

### Closures

```swift
// ✅ Trailing closure syntax
items.map { $0.name }
items.filter { $0.isActive }

// ✅ Named parameters for clarity when not obvious
items.sorted { first, second in
    first.date > second.date
}

// ✅ Multi-line closures
performAnimation {
    self.view.alpha = 1
    self.view.transform = .identity
} completion: { finished in
    self.animationComplete()
}

// ✅ Capture lists to prevent retain cycles
button.onClick = { [weak self] in
    self?.handleTap()
}

// ✅ Capture specific values when needed
let currentIndex = index
Task { [currentIndex] in
    await process(at: currentIndex)
}
```

### Access Control

```swift
// Default to most restrictive, then relax as needed

// ✅ private for implementation details
private let dateFormatter: DateFormatter
private func updateUI()

// ✅ fileprivate rarely — only for extensions in same file
fileprivate func helperMethod()

// ✅ internal (default) for module-internal API
func reload()
var items: [Item]

// ✅ public for framework API
public func configure(with model: Model)

// ✅ open for subclassable/overridable
open class BaseViewController: NSViewController
open func templateMethod()
```

### Final Classes

```swift
// ✅ Default to final — optimize for performance
final class ProfileViewController: NSViewController { }

// ✅ Only remove final when subclassing is intended
class BaseCoordinator { }
final class HomeCoordinator: BaseCoordinator { }
```

## Concurrency

### Async/Await

```swift
// ✅ Prefer async/await over completion handlers
func fetchUser(id: String) async throws -> User {
    let endpoint = Endpoint(path: "/users/\(id)")
    return try await networkService.request(endpoint)
}

// ✅ Structured concurrency with TaskGroup
func fetchAllItems() async throws -> [Item] {
    try await withThrowingTaskGroup(of: Item.self) { group in
        for id in itemIDs {
            group.addTask {
                try await self.fetchItem(id: id)
            }
        }
        
        return try await group.reduce(into: []) { $0.append($1) }
    }
}

// ✅ Task for fire-and-forget async work from sync context
override func viewDidLoad() {
    super.viewDidLoad()
    
    Task {
        await loadData()
    }
}

// ✅ @MainActor for UI updates
@MainActor
func updateUI(with items: [Item]) {
    self.items = items
    tableView.reloadData()
}
```

### Actors

```swift
// ✅ Actor for thread-safe mutable state
actor ImageCache {
    private var cache: [URL: NSImage] = [:]
    
    func image(for url: URL) async throws -> NSImage {
        if let cached = cache[url] {
            return cached
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let image = NSImage(data: data)!
        cache[url] = image
        return image
    }
    
    func clear() {
        cache.removeAll()
    }
}

// ✅ @MainActor for view models
@MainActor
final class MainViewModel {
    private(set) var items: [Item] = []
    var onDataChanged: (() -> Void)?
    
    func loadData() async {
        // Safe to update UI properties
        items = try await service.fetchItems()
        onDataChanged?()
    }
}
```

### Sendable

```swift
// ✅ Mark types as Sendable when safe to pass between threads
struct Item: Sendable {
    let id: String
    let title: String
}

// ✅ Use @unchecked Sendable for types you know are safe
final class ConfigurationManager: @unchecked Sendable {
    // Thread-safe internally via locks
}
```

## Memory Management

### Retain Cycles

```swift
// ✅ Weak references for delegates
weak var delegate: SomeDelegate?

// ✅ Weak self in escaping closures
networkService.fetch { [weak self] result in
    guard let self = self else { return }
    self.handleResult(result)
}

// ✅ Unowned when lifetime is guaranteed
class Parent {
    let child: Child
    
    init() {
        child = Child(parent: self)
    }
}

class Child {
    unowned let parent: Parent  // Parent always outlives Child
    
    init(parent: Parent) {
        self.parent = parent
    }
}
```

### Observation Cleanup

```swift
final class MyViewController: NSViewController {
    
    private var observers: [NSObjectProtocol] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let observer = NotificationCenter.default.addObserver(
            forName: .dataDidUpdate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reload()
        }
        
        observers.append(observer)
    }
    
    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}
```

## Error Handling

### Custom Errors

```swift
// ✅ Domain-specific errors
enum AppError: LocalizedError {
    case networkUnavailable
    case unauthorized
    case invalidData
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network connection unavailable"
        case .unauthorized:
            return "Please log in to continue"
        case .invalidData:
            return "Received invalid data from server"
        case .custom(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection and try again."
        case .unauthorized:
            return "Tap 'Log In' to authenticate."
        default:
            return nil
        }
    }
}
```

### Error Propagation

```swift
// ✅ Propagate errors to caller
func fetchUser() async throws -> User {
    try await networkService.request(.user)
}

// ✅ Handle errors at appropriate level
func loadData() async {
    do {
        items = try await fetchItems()
        updateUI()
    } catch is CancellationError {
        // Task was cancelled — don't show error
    } catch {
        showError(error)
    }
}

// ✅ Map errors to user-friendly messages
func showError(_ error: Error) {
    let message: String
    
    switch error {
    case let appError as AppError:
        message = appError.localizedDescription
    case let urlError as URLError:
        message = urlError.code == .notConnectedToInternet 
            ? "No internet connection"
            : "Network error occurred"
    default:
        message = "An unexpected error occurred"
    }
    
    presentAlert(title: "Error", message: message)
}
```

## AppKit-Specific Patterns

### View Setup (Code-Only)

```swift
final class CustomView: NSView {
    
    private lazy var titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var actionButton: NSButton = {
        let button = NSButton(title: "Action", target: self, action: #selector(actionTapped))
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        wantsLayer = true
        addSubview(titleLabel)
        addSubview(actionButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            actionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func actionTapped(_ sender: NSButton) {
        // Handle action
    }
    
    // MARK: - Configuration
    
    func configure(title: String) {
        titleLabel.stringValue = title
    }
}
```

### NSViewController Lifecycle

```swift
final class ContentViewController: NSViewController {
    
    // Called to create the view (required for code-only)
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
    }
    
    // Called after view is loaded — setup here
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // Called before view appears
    override func viewWillAppear() {
        super.viewWillAppear()
        refreshData()
    }
    
    // Called after view appears
    override func viewDidAppear() {
        super.viewDidAppear()
        becomeFirstResponder()
    }
    
    // Called before view disappears
    override func viewWillDisappear() {
        super.viewWillDisappear()
        saveState()
    }
    
    // Called after view disappears
    override func viewDidDisappear() {
        super.viewDidDisappear()
        cleanup()
    }
}
```

### Responder Chain & Actions

```swift
// ✅ Define actions in the responder chain
extension MainViewController {
    
    @IBAction func copy(_ sender: Any?) {
        guard let selectedItem = selectedItem else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(selectedItem.title, forType: .string)
    }
    
    @IBAction func delete(_ sender: Any?) {
        guard let selectedItem = selectedItem else { return }
        confirmDelete(selectedItem)
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(copy(_:)), #selector(delete(_:)):
            return selectedItem != nil
        default:
            return super.validateMenuItem(menuItem)
        }
    }
}
```

### Menu Construction

```swift
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    private func setupMenus() {
        let mainMenu = NSMenu()
        
        // Application menu
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About MyApp", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit MyApp", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        
        // File menu
        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(withTitle: "New", action: #selector(newDocument), keyEquivalent: "n")
        fileMenu.addItem(withTitle: "Open...", action: #selector(openDocument), keyEquivalent: "o")
        fileMenu.addItem(.separator())
        fileMenu.addItem(withTitle: "Save", action: #selector(saveDocument), keyEquivalent: "s")
        
        let fileMenuItem = NSMenuItem()
        fileMenuItem.submenu = fileMenu
        mainMenu.addItem(fileMenuItem)
        
        // Edit menu
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        
        let editMenuItem = NSMenuItem()
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)
        
        NSApplication.shared.mainMenu = mainMenu
    }
}
```

## UIKit-Specific Patterns

### UIViewController Lifecycle

```swift
final class DetailViewController: UIViewController {
    
    // Called after view is loaded from nib/storyboard or loadView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupNavigation()
    }
    
    // Called every time view is about to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        refreshData()
    }
    
    // Called after view appeared
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimations()
    }
    
    // Called before view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations()
    }
    
    // Called after view disappeared
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanup()
    }
}
```

### Modern Collection Views

```swift
// ✅ Use UICollectionViewCompositionalLayout + DiffableDataSource
final class ItemsViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var dataSource = makeDataSource()
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch Section(rawValue: sectionIndex) {
            case .featured:
                return self.makeFeaturedSection()
            case .list:
                return self.makeListSection()
            default:
                return self.makeListSection()
            }
        }
    }
    
    private func makeFeaturedSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.85),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func makeListSection() -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.showsSeparators = true
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            self?.makeSwipeActions(for: indexPath)
        }
        return NSCollectionLayoutSection.list(using: config, layoutEnvironment: nil)
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            var config = cell.defaultContentConfiguration()
            config.text = item.title
            config.secondaryText = item.subtitle
            config.image = UIImage(systemName: item.iconName)
            cell.contentConfiguration = config
            cell.accessories = [.disclosureIndicator()]
        }
        
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { cv, indexPath, item in
            cv.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.featuredItems, toSection: .featured)
        snapshot.appendItems(viewModel.listItems, toSection: .list)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
```

## Testing Standards

### Test Naming

```swift
// ✅ test_<unit>_<scenario>_<expected>
func test_loadData_withNetworkError_showsErrorAlert()
func test_selectItem_whenItemExists_updatesSelection()
func test_delete_withInvalidIndex_doesNothing()

// ✅ Descriptive test names tell you what broke
func test_loginViewModel_withValidCredentials_setsIsLoggedInTrue()
func test_loginViewModel_withInvalidCredentials_setsErrorMessage()
```

### Test Structure (AAA)

```swift
func test_fetchUser_success_returnsUser() async throws {
    // Arrange
    let expectedUser = User(id: "1", name: "Test")
    mockService.userToReturn = expectedUser
    
    // Act
    let result = try await sut.fetchUser(id: "1")
    
    // Assert
    XCTAssertEqual(result, expectedUser)
    XCTAssertEqual(mockService.fetchUserCallCount, 1)
}
```

### Mocking

```swift
// ✅ Protocol-based mocking
protocol UserServiceProtocol {
    func fetchUser(id: String) async throws -> User
}

final class MockUserService: UserServiceProtocol {
    var userToReturn: User?
    var errorToThrow: Error?
    var fetchUserCallCount = 0
    var fetchUserArguments: [String] = []
    
    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        fetchUserArguments.append(id)
        
        if let error = errorToThrow {
            throw error
        }
        
        guard let user = userToReturn else {
            throw TestError.notConfigured
        }
        
        return user
    }
}
```

## Documentation

### Public API Documentation

```swift
/// Fetches user data from the remote server.
///
/// This method performs a network request to retrieve the user's profile.
/// The response is cached locally for offline access.
///
/// - Parameter id: The unique identifier of the user.
/// - Returns: The requested user object.
/// - Throws: `NetworkError.notFound` if the user doesn't exist.
///           `NetworkError.unauthorized` if authentication is required.
///
/// ## Example
/// ```swift
/// let user = try await userService.fetchUser(id: "12345")
/// print(user.name)
/// ```
public func fetchUser(id: String) async throws -> User
```

### Internal Documentation

```swift
// ✅ Comment the "why", not the "what"

// Bad: Adds 1 to count
count += 1

// Good: Compensate for zero-based index when displaying to user
count += 1

// Good: Rate limit workaround — API returns 429 if called more than 5x/second
await Task.sleep(nanoseconds: 200_000_000)
```

## Anti-Patterns

### What to Avoid

```swift
// ❌ Force unwrapping without guarantees
let user = optionalUser!

// ❌ Implicit unwrapping on properties
var delegate: Delegate!

// ❌ God objects
class AppManager {
    func handleNetwork() { }
    func handleUI() { }
    func handleStorage() { }
    // ... 2000 more lines
}

// ❌ Massive view controllers
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate { }

// ❌ Stringly-typed code
NotificationCenter.default.post(name: NSNotification.Name("userLoggedIn"), object: nil)

// ❌ Callbacks nested in callbacks
fetchUser { user in
    fetchProfile(user) { profile in
        fetchPosts(profile) { posts in
            // Callback hell
        }
    }
}

// ❌ Raw dispatch queues when actors would work
DispatchQueue.global().async {
    // Work
    DispatchQueue.main.async {
        // Update UI
    }
}
```

### Prefer Instead

```swift
// ✅ Safe unwrapping
guard let user = optionalUser else { return }

// ✅ Proper initialization
weak var delegate: Delegate?

// ✅ Single responsibility
class NetworkService { }
class StorageService { }
class UICoordinator { }

// ✅ Coordinator pattern for navigation
class Coordinator {
    func showDetail(for item: Item)
}

// ✅ Typed notifications
extension Notification.Name {
    static let userLoggedIn = Notification.Name("userLoggedIn")
}

// ✅ Async/await
let user = try await fetchUser()
let profile = try await fetchProfile(user)
let posts = try await fetchPosts(profile)

// ✅ Actors for thread safety
actor DataStore {
    func save(_ item: Item) async { }
}

// ✅ @MainActor for UI
@MainActor
func updateUI() { }
```

## Performance Guidelines

### Memory

- Use `weak` for delegates and closure captures
- Implement `deinit` logging in debug builds to detect leaks
- Use `[weak self]` in all escaping closures
- Profile with Instruments Leaks template regularly

### CPU

- Use background queues for heavy computation
- Batch table/collection view updates
- Lazy-load expensive resources
- Cancel unnecessary network requests

### UI

- Keep main thread free — no sync I/O
- Reuse cells in table/collection views
- Use pre-rendering for complex drawings
- Profile with Time Profiler to find bottlenecks
