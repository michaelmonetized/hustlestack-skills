# Swift Architecture Patterns

Detailed implementation patterns for native Apple app development. Reference these when implementing specific architectural concerns.

---

## Table of Contents

1. [Coordinator Pattern](#coordinator-pattern)
2. [Dependency Injection](#dependency-injection)
3. [Repository Pattern](#repository-pattern)
4. [Service Layer](#service-layer)
5. [AppKit Delegate Patterns](#appkit-delegate-patterns)
6. [Multi-Window Architecture](#multi-window-architecture)
7. [Document-Based Apps](#document-based-apps)
8. [Background Services & Agents](#background-services--agents)
9. [Cross-Platform Code Sharing](#cross-platform-code-sharing)
10. [State Management](#state-management)
11. [Navigation Patterns](#navigation-patterns)
12. [Testing Strategies](#testing-strategies)

---

## Coordinator Pattern

Coordinators handle navigation and flow, keeping ViewControllers/Views focused on presentation.

### Basic Coordinator Protocol

```swift
import Foundation

// MARK: - Coordinator Protocol

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}
```

### AppKit Window Coordinator

```swift
import AppKit

// MARK: - Window Coordinator (macOS)

protocol WindowCoordinator: Coordinator {
    var windowController: NSWindowController? { get }
}

final class MainWindowCoordinator: WindowCoordinator {
    var childCoordinators: [Coordinator] = []
    var windowController: NSWindowController?
    
    private let dependencies: Dependencies
    private weak var parentCoordinator: AppCoordinator?
    
    init(dependencies: Dependencies, parent: AppCoordinator) {
        self.dependencies = dependencies
        self.parentCoordinator = parent
    }
    
    func start() {
        let viewModel = MainViewModel(
            documentService: dependencies.documentService,
            settingsService: dependencies.settingsService
        )
        
        let viewController = MainViewController(viewModel: viewModel)
        viewController.coordinator = self
        
        let windowController = MainWindowController(contentViewController: viewController)
        windowController.delegate = self
        self.windowController = windowController
        
        windowController.showWindow(nil)
    }
    
    // MARK: - Navigation
    
    func showPreferences() {
        let prefsCoordinator = PreferencesCoordinator(dependencies: dependencies, parent: self)
        addChild(prefsCoordinator)
        prefsCoordinator.start()
    }
    
    func openDocument(_ document: Document) {
        parentCoordinator?.openDocumentWindow(document)
    }
}

extension MainWindowCoordinator: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        parentCoordinator?.removeChild(self)
    }
}
```

### UIKit Navigation Coordinator

```swift
import UIKit

// MARK: - Navigation Coordinator (iOS)

protocol NavigationCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
}

final class HomeCoordinator: NavigationCoordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    private let dependencies: Dependencies
    
    init(navigationController: UINavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let viewModel = HomeViewModel(
            feedService: dependencies.feedService,
            userService: dependencies.userService
        )
        viewModel.coordinator = self
        
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    // MARK: - Navigation
    
    func showDetail(for item: Item) {
        let detailCoordinator = DetailCoordinator(
            navigationController: navigationController,
            item: item,
            dependencies: dependencies
        )
        addChild(detailCoordinator)
        detailCoordinator.start()
    }
    
    func presentSettings() {
        let settingsNav = UINavigationController()
        let settingsCoordinator = SettingsCoordinator(
            navigationController: settingsNav,
            dependencies: dependencies
        )
        settingsCoordinator.onDismiss = { [weak self] in
            self?.removeChild(settingsCoordinator)
        }
        addChild(settingsCoordinator)
        settingsCoordinator.start()
        
        navigationController.present(settingsNav, animated: true)
    }
}
```

### SwiftUI Coordinator Bridge

```swift
import SwiftUI

// MARK: - SwiftUI Coordinator

@MainActor
final class SwiftUICoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var sheet: SheetDestination?
    @Published var fullScreenCover: FullScreenDestination?
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Navigation
    
    func push(_ destination: AppDestination) {
        path.append(destination)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func present(sheet: SheetDestination) {
        self.sheet = sheet
    }
    
    func present(fullScreen: FullScreenDestination) {
        self.fullScreenCover = fullScreen
    }
    
    func dismiss() {
        sheet = nil
        fullScreenCover = nil
    }
    
    // MARK: - View Building
    
    @ViewBuilder
    func view(for destination: AppDestination) -> some View {
        switch destination {
        case .detail(let item):
            DetailView(viewModel: DetailViewModel(item: item, service: dependencies.itemService))
        case .profile(let user):
            ProfileView(viewModel: ProfileViewModel(user: user, service: dependencies.userService))
        case .settings:
            SettingsView(viewModel: SettingsViewModel(service: dependencies.settingsService))
        }
    }
}

// MARK: - Destinations

enum AppDestination: Hashable {
    case detail(Item)
    case profile(User)
    case settings
}

enum SheetDestination: Identifiable {
    case compose
    case share(Item)
    
    var id: String {
        switch self {
        case .compose: return "compose"
        case .share(let item): return "share-\(item.id)"
        }
    }
}

enum FullScreenDestination: Identifiable {
    case onboarding
    case player(Media)
    
    var id: String {
        switch self {
        case .onboarding: return "onboarding"
        case .player(let media): return "player-\(media.id)"
        }
    }
}
```

---

## Dependency Injection

### Container Pattern

```swift
import Foundation

// MARK: - Dependency Container

protocol Dependencies: AnyObject {
    // Services
    var networkService: NetworkServiceProtocol { get }
    var persistenceService: PersistenceServiceProtocol { get }
    var authService: AuthServiceProtocol { get }
    var analyticsService: AnalyticsServiceProtocol { get }
    
    // Repositories
    var documentRepository: DocumentRepositoryProtocol { get }
    var userRepository: UserRepositoryProtocol { get }
    var settingsRepository: SettingsRepositoryProtocol { get }
}

// MARK: - Production Container

final class AppDependencies: Dependencies {
    // Lazy initialization for services that need setup
    lazy var networkService: NetworkServiceProtocol = {
        URLSessionNetworkService(session: .shared)
    }()
    
    lazy var persistenceService: PersistenceServiceProtocol = {
        CoreDataService(modelName: "AppModel")
    }()
    
    lazy var authService: AuthServiceProtocol = {
        KeychainAuthService(keychain: .standard)
    }()
    
    lazy var analyticsService: AnalyticsServiceProtocol = {
        #if DEBUG
        return ConsoleAnalyticsService()
        #else
        return FirebaseAnalyticsService()
        #endif
    }()
    
    // Repositories depend on services
    lazy var documentRepository: DocumentRepositoryProtocol = {
        CoreDataDocumentRepository(
            persistence: persistenceService,
            network: networkService
        )
    }()
    
    lazy var userRepository: UserRepositoryProtocol = {
        APIUserRepository(
            network: networkService,
            auth: authService
        )
    }()
    
    lazy var settingsRepository: SettingsRepositoryProtocol = {
        UserDefaultsSettingsRepository()
    }()
}

// MARK: - Test Container

final class MockDependencies: Dependencies {
    var networkService: NetworkServiceProtocol = MockNetworkService()
    var persistenceService: PersistenceServiceProtocol = InMemoryPersistenceService()
    var authService: AuthServiceProtocol = MockAuthService()
    var analyticsService: AnalyticsServiceProtocol = NoOpAnalyticsService()
    
    var documentRepository: DocumentRepositoryProtocol = MockDocumentRepository()
    var userRepository: UserRepositoryProtocol = MockUserRepository()
    var settingsRepository: SettingsRepositoryProtocol = InMemorySettingsRepository()
}
```

### Factory Pattern

```swift
// MARK: - View Model Factory

protocol ViewModelFactory {
    func makeMainViewModel() -> MainViewModel
    func makeDetailViewModel(item: Item) -> DetailViewModel
    func makeSettingsViewModel() -> SettingsViewModel
}

final class DefaultViewModelFactory: ViewModelFactory {
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeMainViewModel() -> MainViewModel {
        MainViewModel(
            documentRepository: dependencies.documentRepository,
            settingsRepository: dependencies.settingsRepository
        )
    }
    
    func makeDetailViewModel(item: Item) -> DetailViewModel {
        DetailViewModel(
            item: item,
            documentRepository: dependencies.documentRepository,
            analyticsService: dependencies.analyticsService
        )
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            settingsRepository: dependencies.settingsRepository,
            authService: dependencies.authService
        )
    }
}
```

### Property Wrapper Injection (SwiftUI)

```swift
import SwiftUI

// MARK: - Environment-Based Injection

private struct DependenciesKey: EnvironmentKey {
    static let defaultValue: Dependencies = AppDependencies()
}

extension EnvironmentValues {
    var dependencies: Dependencies {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}

// Usage in App
@main
struct MyApp: App {
    let dependencies = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dependencies, dependencies)
        }
    }
}

// Usage in View
struct DetailView: View {
    @Environment(\.dependencies) private var dependencies
    let item: Item
    
    var body: some View {
        // Use dependencies.documentRepository, etc.
    }
}
```

---

## Repository Pattern

### Repository Protocol

```swift
import Foundation
import Combine

// MARK: - Generic Repository Protocol

protocol Repository {
    associatedtype Entity: Identifiable
    
    func fetch(id: Entity.ID) async throws -> Entity?
    func fetchAll() async throws -> [Entity]
    func save(_ entity: Entity) async throws
    func delete(_ entity: Entity) async throws
}

// MARK: - Document Repository

protocol DocumentRepositoryProtocol {
    func fetchDocument(id: UUID) async throws -> Document?
    func fetchAllDocuments() async throws -> [Document]
    func saveDocument(_ document: Document) async throws
    func deleteDocument(_ document: Document) async throws
    
    // Reactive streams
    func observeDocuments() -> AnyPublisher<[Document], Never>
    func observeDocument(id: UUID) -> AnyPublisher<Document?, Never>
}

// MARK: - Core Data Implementation

final class CoreDataDocumentRepository: DocumentRepositoryProtocol {
    private let context: NSManagedObjectContext
    private let networkService: NetworkServiceProtocol
    
    init(context: NSManagedObjectContext, networkService: NetworkServiceProtocol) {
        self.context = context
        self.networkService = networkService
    }
    
    func fetchDocument(id: UUID) async throws -> Document? {
        try await context.perform {
            let request = DocumentEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            guard let entity = try self.context.fetch(request).first else {
                return nil
            }
            return Document(entity: entity)
        }
    }
    
    func fetchAllDocuments() async throws -> [Document] {
        try await context.perform {
            let request = DocumentEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            
            let entities = try self.context.fetch(request)
            return entities.map(Document.init)
        }
    }
    
    func saveDocument(_ document: Document) async throws {
        try await context.perform {
            let entity = document.toEntity(in: self.context)
            try self.context.save()
        }
        
        // Sync to server
        Task {
            try? await networkService.syncDocument(document)
        }
    }
    
    func deleteDocument(_ document: Document) async throws {
        try await context.perform {
            let request = DocumentEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)
            
            if let entity = try self.context.fetch(request).first {
                self.context.delete(entity)
                try self.context.save()
            }
        }
    }
    
    func observeDocuments() -> AnyPublisher<[Document], Never> {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .compactMap { [weak self] _ -> [Document]? in
                try? self?.fetchAllDocumentsSync()
            }
            .prepend((try? fetchAllDocumentsSync()) ?? [])
            .eraseToAnyPublisher()
    }
    
    func observeDocument(id: UUID) -> AnyPublisher<Document?, Never> {
        observeDocuments()
            .map { documents in documents.first { $0.id == id } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private func fetchAllDocumentsSync() throws -> [Document] {
        let request = DocumentEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return try context.fetch(request).map(Document.init)
    }
}
```

### In-Memory Repository (Testing)

```swift
// MARK: - In-Memory Implementation (for testing)

final class InMemoryDocumentRepository: DocumentRepositoryProtocol {
    private var documents: [UUID: Document] = [:]
    private let subject = CurrentValueSubject<[Document], Never>([])
    
    func fetchDocument(id: UUID) async throws -> Document? {
        documents[id]
    }
    
    func fetchAllDocuments() async throws -> [Document] {
        Array(documents.values).sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func saveDocument(_ document: Document) async throws {
        documents[document.id] = document
        subject.send(try await fetchAllDocuments())
    }
    
    func deleteDocument(_ document: Document) async throws {
        documents.removeValue(forKey: document.id)
        subject.send(try await fetchAllDocuments())
    }
    
    func observeDocuments() -> AnyPublisher<[Document], Never> {
        subject.eraseToAnyPublisher()
    }
    
    func observeDocument(id: UUID) -> AnyPublisher<Document?, Never> {
        subject
            .map { $0.first { $0.id == id } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // Test helpers
    func reset() {
        documents.removeAll()
        subject.send([])
    }
    
    func seed(with documents: [Document]) {
        self.documents = Dictionary(uniqueKeysWithValues: documents.map { ($0.id, $0) })
        subject.send(Array(self.documents.values))
    }
}
```

---

## Service Layer

### Service Protocol Pattern

```swift
// MARK: - Network Service

protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func upload(data: Data, to endpoint: Endpoint) async throws -> UploadResponse
    func download(from endpoint: Endpoint) async throws -> Data
}

final class URLSessionNetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.urlRequest()
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
    func upload(data: Data, to endpoint: Endpoint) async throws -> UploadResponse {
        var request = try endpoint.urlRequest()
        request.httpBody = data
        request.httpMethod = "POST"
        
        let (responseData, _) = try await session.data(for: request)
        return try decoder.decode(UploadResponse.self, from: responseData)
    }
    
    func download(from endpoint: Endpoint) async throws -> Data {
        let request = try endpoint.urlRequest()
        let (data, _) = try await session.data(for: request)
        return data
    }
}

// MARK: - Endpoint

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let body: Encodable?
    
    func urlRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.example.com"
        components.path = path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingError(Error)
}
```

### Domain Service

```swift
// MARK: - Document Service (Domain Logic)

protocol DocumentServiceProtocol {
    func createDocument(title: String, content: String) async throws -> Document
    func updateDocument(_ document: Document, title: String?, content: String?) async throws -> Document
    func duplicateDocument(_ document: Document) async throws -> Document
    func exportDocument(_ document: Document, format: ExportFormat) async throws -> Data
    func validateDocument(_ document: Document) throws -> [ValidationError]
}

final class DocumentService: DocumentServiceProtocol {
    private let repository: DocumentRepositoryProtocol
    private let validator: DocumentValidator
    private let exporter: DocumentExporter
    
    init(
        repository: DocumentRepositoryProtocol,
        validator: DocumentValidator = .init(),
        exporter: DocumentExporter = .init()
    ) {
        self.repository = repository
        self.validator = validator
        self.exporter = exporter
    }
    
    func createDocument(title: String, content: String) async throws -> Document {
        let document = Document(
            id: UUID(),
            title: title,
            content: content,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let errors = try validateDocument(document)
        guard errors.isEmpty else {
            throw DocumentError.validationFailed(errors)
        }
        
        try await repository.saveDocument(document)
        return document
    }
    
    func updateDocument(_ document: Document, title: String?, content: String?) async throws -> Document {
        var updated = document
        if let title = title { updated.title = title }
        if let content = content { updated.content = content }
        updated.updatedAt = Date()
        
        let errors = try validateDocument(updated)
        guard errors.isEmpty else {
            throw DocumentError.validationFailed(errors)
        }
        
        try await repository.saveDocument(updated)
        return updated
    }
    
    func duplicateDocument(_ document: Document) async throws -> Document {
        let duplicate = Document(
            id: UUID(),
            title: "\(document.title) (Copy)",
            content: document.content,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await repository.saveDocument(duplicate)
        return duplicate
    }
    
    func exportDocument(_ document: Document, format: ExportFormat) async throws -> Data {
        try await exporter.export(document, format: format)
    }
    
    func validateDocument(_ document: Document) throws -> [ValidationError] {
        validator.validate(document)
    }
}
```

---

## AppKit Delegate Patterns

### Modern AppDelegate

```swift
import AppKit

// MARK: - App Delegate (macOS)

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appCoordinator: AppCoordinator?
    private var dependencies: Dependencies?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupDependencies()
        setupCoordinator()
        setupMenuBar()
        
        appCoordinator?.start()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        saveApplicationState()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Return false for menu bar apps or document-based apps
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            appCoordinator?.showMainWindow()
        }
        return true
    }
    
    // MARK: - Setup
    
    private func setupDependencies() {
        dependencies = AppDependencies()
    }
    
    private func setupCoordinator() {
        guard let dependencies = dependencies else { return }
        appCoordinator = AppCoordinator(dependencies: dependencies)
    }
    
    private func setupMenuBar() {
        // Menu items are typically set up in Main.storyboard/XIB
        // or programmatically here
    }
    
    private func saveApplicationState() {
        // Save any pending state
    }
    
    // MARK: - Menu Actions
    
    @IBAction func newDocument(_ sender: Any?) {
        appCoordinator?.createNewDocument()
    }
    
    @IBAction func openPreferences(_ sender: Any?) {
        appCoordinator?.showPreferences()
    }
}
```

### Window Controller

```swift
import AppKit

// MARK: - Window Controller

final class MainWindowController: NSWindowController {
    
    // Restoration identifier for state restoration
    static let restorationIdentifier = NSUserInterfaceItemIdentifier("MainWindow")
    
    convenience init(contentViewController: NSViewController) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "My App"
        window.contentViewController = contentViewController
        window.center()
        window.setFrameAutosaveName("MainWindow")
        window.identifier = Self.restorationIdentifier
        window.isRestorable = true
        
        // Minimum size
        window.minSize = NSSize(width: 400, height: 300)
        
        self.init(window: window)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Configure toolbar if needed
        setupToolbar()
    }
    
    private func setupToolbar() {
        let toolbar = NSToolbar(identifier: "MainToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        
        window?.toolbar = toolbar
        window?.toolbarStyle = .unified
    }
}

// MARK: - Toolbar Delegate

extension MainWindowController: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .add, .search]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .space, .add, .search, .share]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .add:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Add"
            item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: "Add")
            item.action = #selector(addAction(_:))
            item.target = self
            return item
            
        case .search:
            let searchItem = NSSearchToolbarItem(itemIdentifier: itemIdentifier)
            searchItem.searchField.delegate = self
            return searchItem
            
        default:
            return nil
        }
    }
    
    @objc private func addAction(_ sender: Any?) {
        // Handle add action
    }
}

extension MainWindowController: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let searchField = obj.object as? NSSearchField else { return }
        // Handle search
    }
}

// MARK: - Toolbar Item Identifiers

extension NSToolbarItem.Identifier {
    static let add = NSToolbarItem.Identifier("add")
    static let search = NSToolbarItem.Identifier("search")
}
```

### View Controller with ViewModel

```swift
import AppKit
import Combine

// MARK: - View Controller

final class MainViewController: NSViewController {
    
    // MARK: - Properties
    
    private let viewModel: MainViewModel
    weak var coordinator: MainWindowCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private lazy var tableView: NSTableView = {
        let table = NSTableView()
        table.delegate = self
        table.dataSource = self
        table.usesAlternatingRowBackgroundColors = true
        table.allowsMultipleSelection = false
        
        let column = NSTableColumn(identifier: .init("main"))
        column.title = "Documents"
        table.addTableColumn(column)
        table.headerView = nil
        
        return table
    }()
    
    private lazy var scrollView: NSScrollView = {
        let scroll = NSScrollView()
        scroll.documentView = tableView
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        return scroll
    }()
    
    // MARK: - Initialization
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        
        setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        viewModel.loadDocuments()
    }
    
    // MARK: - Setup
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$documents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // Show/hide loading indicator
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ error: Error) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Error"
        alert.informativeText = error.localizedDescription
        alert.runModal()
    }
}

// MARK: - Table View Data Source

extension MainViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        viewModel.documents.count
    }
}

// MARK: - Table View Delegate

extension MainViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let document = viewModel.documents[row]
        
        let cellIdentifier = NSUserInterfaceItemIdentifier("DocumentCell")
        let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView
            ?? NSTableCellView()
        
        cell.identifier = cellIdentifier
        cell.textField?.stringValue = document.title
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow >= 0 else { return }
        let document = viewModel.documents[tableView.selectedRow]
        coordinator?.openDocument(document)
    }
}
```

---

## Multi-Window Architecture

### Window Manager

```swift
import AppKit

// MARK: - Window Manager

@MainActor
final class WindowManager {
    static let shared = WindowManager()
    
    private var windowControllers: [ObjectIdentifier: NSWindowController] = [:]
    private var documentWindows: [UUID: DocumentWindowController] = [:]
    
    private init() {}
    
    // MARK: - Window Registration
    
    func register(_ windowController: NSWindowController) {
        let id = ObjectIdentifier(windowController)
        windowControllers[id] = windowController
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: windowController.window
        )
    }
    
    func registerDocument(_ windowController: DocumentWindowController, for documentId: UUID) {
        documentWindows[documentId] = windowController
        register(windowController)
    }
    
    @objc private func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        
        // Find and remove the window controller
        for (id, controller) in windowControllers {
            if controller.window === window {
                windowControllers.removeValue(forKey: id)
                break
            }
        }
        
        // Remove from document windows if applicable
        for (docId, controller) in documentWindows {
            if controller.window === window {
                documentWindows.removeValue(forKey: docId)
                break
            }
        }
    }
    
    // MARK: - Window Access
    
    func windowController(for documentId: UUID) -> DocumentWindowController? {
        documentWindows[documentId]
    }
    
    func focusWindow(for documentId: UUID) -> Bool {
        guard let controller = documentWindows[documentId] else { return false }
        controller.window?.makeKeyAndOrderFront(nil)
        return true
    }
    
    func allDocumentWindows() -> [DocumentWindowController] {
        Array(documentWindows.values)
    }
    
    // MARK: - Window Arrangement
    
    func cascadeWindows() {
        var offset = CGPoint(x: 20, y: 20)
        for controller in windowControllers.values {
            controller.window?.setFrameOrigin(offset)
            offset.x += 20
            offset.y += 20
        }
    }
    
    func tileWindows() {
        guard let screen = NSScreen.main else { return }
        let visibleFrame = screen.visibleFrame
        let windows = Array(windowControllers.values.compactMap { $0.window })
        
        guard !windows.isEmpty else { return }
        
        let columns = Int(ceil(sqrt(Double(windows.count))))
        let rows = Int(ceil(Double(windows.count) / Double(columns)))
        
        let width = visibleFrame.width / CGFloat(columns)
        let height = visibleFrame.height / CGFloat(rows)
        
        for (index, window) in windows.enumerated() {
            let col = index % columns
            let row = index / columns
            
            let frame = NSRect(
                x: visibleFrame.minX + CGFloat(col) * width,
                y: visibleFrame.maxY - CGFloat(row + 1) * height,
                width: width,
                height: height
            )
            window.setFrame(frame, display: true, animate: true)
        }
    }
}
```

### Multi-Window Coordinator

```swift
import AppKit

// MARK: - App Coordinator (Multi-Window)

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    private let dependencies: Dependencies
    private let windowManager = WindowManager.shared
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func start() {
        showMainWindow()
    }
    
    // MARK: - Main Window
    
    func showMainWindow() {
        let coordinator = MainWindowCoordinator(dependencies: dependencies, parent: self)
        addChild(coordinator)
        coordinator.start()
    }
    
    // MARK: - Document Windows
    
    func openDocumentWindow(_ document: Document) {
        // Check if window already exists
        if windowManager.focusWindow(for: document.id) {
            return
        }
        
        // Create new window
        let coordinator = DocumentWindowCoordinator(
            document: document,
            dependencies: dependencies,
            parent: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    func closeAllDocumentWindows() {
        for controller in windowManager.allDocumentWindows() {
            controller.close()
        }
    }
    
    // MARK: - Preferences
    
    private var preferencesCoordinator: PreferencesCoordinator?
    
    func showPreferences() {
        if let existing = preferencesCoordinator {
            existing.windowController?.showWindow(nil)
            return
        }
        
        let coordinator = PreferencesCoordinator(dependencies: dependencies, parent: self)
        preferencesCoordinator = coordinator
        coordinator.onDismiss = { [weak self] in
            self?.preferencesCoordinator = nil
        }
        addChild(coordinator)
        coordinator.start()
    }
    
    // MARK: - Window Management
    
    func cascadeAllWindows() {
        windowManager.cascadeWindows()
    }
    
    func tileAllWindows() {
        windowManager.tileWindows()
    }
}
```

---

## Document-Based Apps

### NSDocument Subclass

```swift
import AppKit
import UniformTypeIdentifiers

// MARK: - Document

final class TextDocument: NSDocument {
    
    // MARK: - Properties
    
    var content: String = ""
    
    // MARK: - NSDocument Overrides
    
    override class var autosavesInPlace: Bool { true }
    override class var autosavesDrafts: Bool { true }
    override class var preservesVersions: Bool { true }
    
    override var windowNibName: NSNib.Name? {
        // Return XIB name if using Interface Builder
        nil
    }
    
    override func makeWindowControllers() {
        let viewModel = DocumentViewModel(document: self)
        let viewController = DocumentViewController(viewModel: viewModel)
        let windowController = DocumentWindowController(contentViewController: viewController)
        
        addWindowController(windowController)
    }
    
    // MARK: - Reading & Writing
    
    override func read(from data: Data, ofType typeName: String) throws {
        guard let content = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.content = content
    }
    
    override func data(ofType typeName: String) throws -> Data {
        guard let data = content.data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return data
    }
    
    // MARK: - File Types
    
    override class func readableTypes() -> [String] {
        [UTType.plainText.identifier, UTType.utf8PlainText.identifier]
    }
    
    override class func writableTypes(forSaveOperation saveOperation: NSDocument.SaveOperationType) -> [String] {
        [UTType.plainText.identifier]
    }
    
    override class func isNativeType(_ type: String) -> Bool {
        type == UTType.plainText.identifier
    }
    
    // MARK: - Printing
    
    override func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey: Any]) throws -> NSPrintOperation {
        let printInfo = NSPrintInfo(dictionary: printSettings)
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 468, height: 648))
        textView.string = content
        return NSPrintOperation(view: textView, printInfo: printInfo)
    }
}
```

### Document Controller

```swift
import AppKit

// MARK: - Custom Document Controller

final class AppDocumentController: NSDocumentController {
    
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        let document = try super.openUntitledDocumentAndDisplay(displayDocument)
        
        // Custom initialization for new documents
        if let textDoc = document as? TextDocument {
            textDoc.content = "# New Document\n\nStart writing..."
        }
        
        return document
    }
    
    override func makeDocument(withContentsOf url: URL, ofType typeName: String) throws -> NSDocument {
        let document = try super.makeDocument(withContentsOf: url, ofType: typeName)
        
        // Post-processing after loading
        NotificationCenter.default.post(name: .documentDidOpen, object: document)
        
        return document
    }
    
    // MARK: - Recent Documents
    
    func clearRecentDocuments() {
        clearRecentDocuments(nil)
    }
    
    func addToRecents(_ url: URL) {
        noteNewRecentDocumentURL(url)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let documentDidOpen = Notification.Name("documentDidOpen")
    static let documentWillClose = Notification.Name("documentWillClose")
}
```

---

## Background Services & Agents

### Menu Bar Agent (LSUIElement)

```swift
import AppKit

// MARK: - Menu Bar App Delegate

@main
final class AgentAppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var dependencies: Dependencies?
    private var coordinator: AgentCoordinator?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        dependencies = AppDependencies()
        
        setupStatusItem()
        setupPopover()
        setupCoordinator()
    }
    
    // MARK: - Status Item
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else { return }
        
        button.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "App Status")
        button.action = #selector(togglePopover(_:))
        button.target = self
        
        // Support right-click menu
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    private func setupPopover() {
        guard let dependencies = dependencies else { return }
        
        let viewModel = StatusViewModel(service: dependencies.statusService)
        let viewController = StatusViewController(viewModel: viewModel)
        
        popover = NSPopover()
        popover?.contentViewController = viewController
        popover?.behavior = .transient
        popover?.animates = true
    }
    
    private func setupCoordinator() {
        guard let dependencies = dependencies else { return }
        coordinator = AgentCoordinator(dependencies: dependencies)
        coordinator?.start()
    }
    
    // MARK: - Actions
    
    @objc private func togglePopover(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            if popover?.isShown == true {
                closePopover()
            } else {
                showPopover()
            }
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
        menu.addItem(withTitle: "Open Main Window", action: #selector(openMainWindow), keyEquivalent: "o")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil // Reset so left-click works normally
    }
    
    @objc private func openMainWindow() {
        coordinator?.showMainWindow()
    }
    
    @objc private func openPreferences() {
        coordinator?.showPreferences()
    }
    
    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
```

### Background Service (LaunchAgent)

```swift
import Foundation

// MARK: - Background Service

@main
struct BackgroundService {
    static func main() async {
        let service = ServiceController()
        await service.run()
    }
}

// MARK: - Service Controller

actor ServiceController {
    private var isRunning = true
    private let fileWatcher: FileWatcher
    private let syncService: SyncService
    
    init() {
        self.fileWatcher = FileWatcher()
        self.syncService = SyncService()
    }
    
    func run() async {
        setupSignalHandlers()
        
        await startServices()
        
        // Keep running until terminated
        while isRunning {
            try? await Task.sleep(for: .seconds(1))
        }
        
        await stopServices()
    }
    
    private func startServices() async {
        await fileWatcher.start()
        await syncService.start()
        
        log("Services started")
    }
    
    private func stopServices() async {
        await fileWatcher.stop()
        await syncService.stop()
        
        log("Services stopped")
    }
    
    private func setupSignalHandlers() {
        let signalSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
        signalSource.setEventHandler { [weak self] in
            Task { await self?.shutdown() }
        }
        signalSource.resume()
        signal(SIGTERM, SIG_IGN)
        
        let intSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
        intSource.setEventHandler { [weak self] in
            Task { await self?.shutdown() }
        }
        intSource.resume()
        signal(SIGINT, SIG_IGN)
    }
    
    func shutdown() {
        isRunning = false
    }
    
    private func log(_ message: String) {
        let formatter = ISO8601DateFormatter()
        print("[\(formatter.string(from: Date()))] \(message)")
    }
}

// MARK: - File Watcher

actor FileWatcher {
    private var source: DispatchSourceFileSystemObject?
    private let watchedURL: URL
    
    init(url: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Documents")) {
        self.watchedURL = url
    }
    
    func start() {
        let fd = open(watchedURL.path, O_EVTONLY)
        guard fd >= 0 else { return }
        
        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename],
            queue: .global()
        )
        
        source?.setEventHandler { [weak self] in
            Task { await self?.handleFileChange() }
        }
        
        source?.setCancelHandler {
            close(fd)
        }
        
        source?.resume()
    }
    
    func stop() {
        source?.cancel()
        source = nil
    }
    
    private func handleFileChange() {
        // Process file system changes
    }
}
```

### LaunchAgent Plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.backgroundservice</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/MyApp.app/Contents/MacOS/BackgroundService</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    
    <key>StandardOutPath</key>
    <string>/tmp/com.example.backgroundservice.stdout</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/com.example.backgroundservice.stderr</string>
    
    <key>ProcessType</key>
    <string>Background</string>
</dict>
</plist>
```

---

## Cross-Platform Code Sharing

### Project Structure

```
MyApp/
├── Package.swift                    # Swift Package for shared code
├── Sources/
│   ├── SharedCore/                  # Pure Swift, no platform dependencies
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Repositories/
│   │   └── Utilities/
│   ├── SharedUI/                    # Cross-platform SwiftUI
│   │   ├── Components/
│   │   ├── ViewModels/
│   │   └── Styles/
│   ├── PlatformMac/                 # macOS-specific (AppKit extensions)
│   │   └── Extensions/
│   └── PlatformIOS/                 # iOS-specific (UIKit extensions)
│       └── Extensions/
├── Tests/
│   └── SharedCoreTests/
├── Apps/
│   ├── MyAppMac/                    # macOS app target
│   │   ├── MyAppMac.xcodeproj
│   │   └── Sources/
│   └── MyAppIOS/                    # iOS app target
│       ├── MyAppIOS.xcodeproj
│       └── Sources/
```

### Package.swift

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyAppShared",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(name: "SharedCore", targets: ["SharedCore"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
        .library(name: "PlatformMac", targets: ["PlatformMac"]),
        .library(name: "PlatformIOS", targets: ["PlatformIOS"]),
    ],
    dependencies: [
        // Add external dependencies here
    ],
    targets: [
        // Core business logic - no platform dependencies
        .target(
            name: "SharedCore",
            dependencies: []
        ),
        
        // Shared SwiftUI components
        .target(
            name: "SharedUI",
            dependencies: ["SharedCore"]
        ),
        
        // macOS-specific code
        .target(
            name: "PlatformMac",
            dependencies: ["SharedCore", "SharedUI"]
        ),
        
        // iOS-specific code
        .target(
            name: "PlatformIOS",
            dependencies: ["SharedCore", "SharedUI"]
        ),
        
        // Tests
        .testTarget(
            name: "SharedCoreTests",
            dependencies: ["SharedCore"]
        ),
    ]
)
```

### Platform Abstraction

```swift
// MARK: - Platform Abstraction

// In SharedCore - define protocols
protocol PlatformServiceProtocol {
    func openURL(_ url: URL) async -> Bool
    func copyToClipboard(_ string: String)
    func showShareSheet(items: [Any], from source: Any?)
}

// In PlatformMac
#if os(macOS)
import AppKit

final class MacPlatformService: PlatformServiceProtocol {
    func openURL(_ url: URL) async -> Bool {
        NSWorkspace.shared.open(url)
    }
    
    func copyToClipboard(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }
    
    func showShareSheet(items: [Any], from source: Any?) {
        guard let view = source as? NSView else { return }
        let picker = NSSharingServicePicker(items: items)
        picker.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }
}
#endif

// In PlatformIOS
#if os(iOS)
import UIKit

final class IOSPlatformService: PlatformServiceProtocol {
    func openURL(_ url: URL) async -> Bool {
        await UIApplication.shared.open(url)
    }
    
    func copyToClipboard(_ string: String) {
        UIPasteboard.general.string = string
    }
    
    func showShareSheet(items: [Any], from source: Any?) {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let popover = controller.popoverPresentationController,
           let sourceView = source as? UIView {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true)
    }
}
#endif

// Factory
enum PlatformServiceFactory {
    static func make() -> PlatformServiceProtocol {
        #if os(macOS)
        return MacPlatformService()
        #elseif os(iOS)
        return IOSPlatformService()
        #endif
    }
}
```

### Conditional Compilation

```swift
// MARK: - Conditional Compilation Patterns

// Type aliases for cross-platform compatibility
#if os(macOS)
import AppKit
public typealias PlatformColor = NSColor
public typealias PlatformImage = NSImage
public typealias PlatformFont = NSFont
public typealias PlatformViewController = NSViewController
#elseif os(iOS)
import UIKit
public typealias PlatformColor = UIColor
public typealias PlatformImage = UIImage
public typealias PlatformFont = UIFont
public typealias PlatformViewController = UIViewController
#endif

// Extension with platform-specific implementations
extension PlatformColor {
    static var systemBackground: PlatformColor {
        #if os(macOS)
        return .windowBackgroundColor
        #else
        return .systemBackground
        #endif
    }
    
    static var label: PlatformColor {
        #if os(macOS)
        return .labelColor
        #else
        return .label
        #endif
    }
}

// SwiftUI view with platform variants
struct AdaptiveButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
        }
        #if os(macOS)
        .buttonStyle(.bordered)
        .controlSize(.large)
        #else
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
        #endif
    }
}
```

---

## State Management

### ViewModel with Combine

```swift
import Foundation
import Combine

// MARK: - ViewModel Base

@MainActor
class ViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
}

// MARK: - Concrete ViewModel

@MainActor
final class DocumentListViewModel: ViewModel {
    
    // MARK: - Published State
    
    @Published private(set) var documents: [Document] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var searchQuery = ""
    @Published var sortOrder: SortOrder = .dateDescending
    
    // MARK: - Computed
    
    var filteredDocuments: [Document] {
        var result = documents
        
        if !searchQuery.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
        }
        
        switch sortOrder {
        case .dateAscending:
            result.sort { $0.updatedAt < $1.updatedAt }
        case .dateDescending:
            result.sort { $0.updatedAt > $1.updatedAt }
        case .titleAscending:
            result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleDescending:
            result.sort { $0.title.localizedCompare($1.title) == .orderedDescending }
        }
        
        return result
    }
    
    // MARK: - Dependencies
    
    private let repository: DocumentRepositoryProtocol
    
    // MARK: - Init
    
    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
        super.init()
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        repository.observeDocuments()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] documents in
                self?.documents = documents
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    func loadDocuments() {
        Task {
            isLoading = true
            error = nil
            
            do {
                documents = try await repository.fetchAllDocuments()
            } catch {
                self.error = error
            }
            
            isLoading = false
        }
    }
    
    func deleteDocument(_ document: Document) {
        Task {
            do {
                try await repository.deleteDocument(document)
            } catch {
                self.error = error
            }
        }
    }
    
    func refresh() {
        loadDocuments()
    }
}

// MARK: - Sort Order

enum SortOrder: String, CaseIterable, Identifiable {
    case dateDescending = "Newest First"
    case dateAscending = "Oldest First"
    case titleAscending = "Title A-Z"
    case titleDescending = "Title Z-A"
    
    var id: String { rawValue }
}
```

### State Restoration (AppKit)

```swift
import AppKit

// MARK: - Restorable Window Controller

final class RestorableWindowController: NSWindowController, NSWindowRestoration {
    
    // MARK: - State Keys
    
    private enum StateKey {
        static let documentURL = "documentURL"
        static let scrollPosition = "scrollPosition"
        static let selectedRange = "selectedRange"
    }
    
    // MARK: - Restoration Class Method
    
    static func restoreWindow(
        withIdentifier identifier: NSUserInterfaceItemIdentifier,
        state: NSCoder,
        completionHandler: @escaping (NSWindow?, Error?) -> Void
    ) {
        // Restore from saved state
        guard let urlString = state.decodeObject(forKey: StateKey.documentURL) as? String,
              let url = URL(string: urlString) else {
            completionHandler(nil, nil)
            return
        }
        
        // Recreate the window
        NSDocumentController.shared.openDocument(
            withContentsOf: url,
            display: true
        ) { document, alreadyOpen, error in
            if let document = document {
                completionHandler(document.windowControllers.first?.window, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    // MARK: - Encode State
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        // Save document URL
        if let url = document?.fileURL {
            coder.encode(url.absoluteString, forKey: StateKey.documentURL)
        }
        
        // Save scroll position
        if let scrollView = contentViewController?.view.subviews.first as? NSScrollView {
            let point = scrollView.contentView.bounds.origin
            coder.encode(NSStringFromPoint(point), forKey: StateKey.scrollPosition)
        }
    }
    
    // MARK: - Restore State
    
    override func restoreState(with coder: NSCoder) {
        super.restoreState(with: coder)
        
        // Restore scroll position
        if let pointString = coder.decodeObject(forKey: StateKey.scrollPosition) as? String,
           let scrollView = contentViewController?.view.subviews.first as? NSScrollView {
            let point = NSPointFromString(pointString)
            scrollView.contentView.scroll(to: point)
        }
    }
}
```

---

## Navigation Patterns

### Tab-Based Navigation (SwiftUI, Cross-Platform)

```swift
import SwiftUI

// MARK: - Tab Navigation

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case search
    case library
    case settings
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .library: return "Library"
        case .settings: return "Settings"
        }
    }
    
    var systemImage: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical"
        case .settings: return "gear"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @StateObject private var coordinator: AppCoordinator
    
    init(dependencies: Dependencies) {
        _coordinator = StateObject(wrappedValue: AppCoordinator(dependencies: dependencies))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
            }
        }
        .environmentObject(coordinator)
    }
    
    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            NavigationStack(path: $coordinator.homePath) {
                HomeView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        coordinator.view(for: destination)
                    }
            }
        case .search:
            NavigationStack(path: $coordinator.searchPath) {
                SearchView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        coordinator.view(for: destination)
                    }
            }
        case .library:
            NavigationStack(path: $coordinator.libraryPath) {
                LibraryView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        coordinator.view(for: destination)
                    }
            }
        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }
}
```

### Split View Navigation (macOS)

```swift
import SwiftUI

// MARK: - Split View (macOS)

struct SplitContentView: View {
    @StateObject private var coordinator: SplitCoordinator
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    init(dependencies: Dependencies) {
        _coordinator = StateObject(wrappedValue: SplitCoordinator(dependencies: dependencies))
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            SidebarView(selection: $coordinator.selectedSection)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 300)
        } content: {
            // Content list
            if let section = coordinator.selectedSection {
                ContentListView(section: section, selection: $coordinator.selectedItem)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 280, max: 400)
            } else {
                Text("Select a section")
                    .foregroundStyle(.secondary)
            }
        } detail: {
            // Detail
            if let item = coordinator.selectedItem {
                DetailView(item: item)
            } else {
                Text("Select an item")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .environmentObject(coordinator)
    }
}

// MARK: - Split Coordinator

@MainActor
final class SplitCoordinator: ObservableObject {
    @Published var selectedSection: Section?
    @Published var selectedItem: Item?
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}
```

---

## Testing Strategies

### ViewModel Testing

```swift
import XCTest
import Combine
@testable import MyApp

final class DocumentListViewModelTests: XCTestCase {
    
    private var sut: DocumentListViewModel!
    private var mockRepository: MockDocumentRepository!
    private var cancellables: Set<AnyCancellable>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockRepository = MockDocumentRepository()
        sut = DocumentListViewModel(repository: mockRepository)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    @MainActor
    func testLoadDocuments_Success() async {
        // Given
        let expectedDocuments = [
            Document(id: UUID(), title: "Doc 1", content: "Content", createdAt: Date(), updatedAt: Date()),
            Document(id: UUID(), title: "Doc 2", content: "Content", createdAt: Date(), updatedAt: Date())
        ]
        mockRepository.documentsToReturn = expectedDocuments
        
        // When
        sut.loadDocuments()
        
        // Allow async to complete
        await Task.yield()
        
        // Then
        XCTAssertEqual(sut.documents.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    @MainActor
    func testLoadDocuments_Error() async {
        // Given
        mockRepository.errorToThrow = NSError(domain: "test", code: 1)
        
        // When
        sut.loadDocuments()
        
        await Task.yield()
        
        // Then
        XCTAssertTrue(sut.documents.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.error)
    }
    
    @MainActor
    func testFilteredDocuments_WithSearchQuery() {
        // Given
        sut.documents = [
            Document(id: UUID(), title: "Swift Guide", content: "", createdAt: Date(), updatedAt: Date()),
            Document(id: UUID(), title: "Kotlin Guide", content: "", createdAt: Date(), updatedAt: Date()),
            Document(id: UUID(), title: "Swift Tips", content: "", createdAt: Date(), updatedAt: Date())
        ]
        
        // When
        sut.searchQuery = "Swift"
        
        // Then
        XCTAssertEqual(sut.filteredDocuments.count, 2)
        XCTAssertTrue(sut.filteredDocuments.allSatisfy { $0.title.contains("Swift") })
    }
    
    @MainActor
    func testFilteredDocuments_SortOrder() {
        // Given
        let older = Date().addingTimeInterval(-3600)
        let newer = Date()
        
        sut.documents = [
            Document(id: UUID(), title: "Older", content: "", createdAt: older, updatedAt: older),
            Document(id: UUID(), title: "Newer", content: "", createdAt: newer, updatedAt: newer)
        ]
        
        // When - sort newest first
        sut.sortOrder = .dateDescending
        
        // Then
        XCTAssertEqual(sut.filteredDocuments.first?.title, "Newer")
        
        // When - sort oldest first
        sut.sortOrder = .dateAscending
        
        // Then
        XCTAssertEqual(sut.filteredDocuments.first?.title, "Older")
    }
}

// MARK: - Mock Repository

final class MockDocumentRepository: DocumentRepositoryProtocol {
    var documentsToReturn: [Document] = []
    var errorToThrow: Error?
    var savedDocuments: [Document] = []
    var deletedDocuments: [Document] = []
    
    private let subject = CurrentValueSubject<[Document], Never>([])
    
    func fetchDocument(id: UUID) async throws -> Document? {
        if let error = errorToThrow { throw error }
        return documentsToReturn.first { $0.id == id }
    }
    
    func fetchAllDocuments() async throws -> [Document] {
        if let error = errorToThrow { throw error }
        return documentsToReturn
    }
    
    func saveDocument(_ document: Document) async throws {
        if let error = errorToThrow { throw error }
        savedDocuments.append(document)
    }
    
    func deleteDocument(_ document: Document) async throws {
        if let error = errorToThrow { throw error }
        deletedDocuments.append(document)
    }
    
    func observeDocuments() -> AnyPublisher<[Document], Never> {
        subject.eraseToAnyPublisher()
    }
    
    func observeDocument(id: UUID) -> AnyPublisher<Document?, Never> {
        subject
            .map { $0.first { $0.id == id } }
            .eraseToAnyPublisher()
    }
    
    // Test helper
    func emit(_ documents: [Document]) {
        subject.send(documents)
    }
}
```

### Integration Testing

```swift
import XCTest
@testable import MyApp

final class DocumentServiceIntegrationTests: XCTestCase {
    
    private var sut: DocumentService!
    private var repository: InMemoryDocumentRepository!
    
    override func setUp() {
        super.setUp()
        repository = InMemoryDocumentRepository()
        sut = DocumentService(repository: repository)
    }
    
    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }
    
    func testCreateAndFetchDocument() async throws {
        // Create
        let document = try await sut.createDocument(title: "Test", content: "Content")
        
        // Fetch
        let fetched = try await repository.fetchDocument(id: document.id)
        
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.title, "Test")
        XCTAssertEqual(fetched?.content, "Content")
    }
    
    func testUpdateDocument() async throws {
        // Create
        let document = try await sut.createDocument(title: "Original", content: "Content")
        
        // Update
        let updated = try await sut.updateDocument(document, title: "Updated", content: nil)
        
        XCTAssertEqual(updated.title, "Updated")
        XCTAssertEqual(updated.content, "Content") // Unchanged
        XCTAssertGreaterThan(updated.updatedAt, document.updatedAt)
    }
    
    func testDuplicateDocument() async throws {
        // Create original
        let original = try await sut.createDocument(title: "Original", content: "Content")
        
        // Duplicate
        let duplicate = try await sut.duplicateDocument(original)
        
        XCTAssertNotEqual(duplicate.id, original.id)
        XCTAssertEqual(duplicate.title, "Original (Copy)")
        XCTAssertEqual(duplicate.content, original.content)
        
        // Both should exist
        let all = try await repository.fetchAllDocuments()
        XCTAssertEqual(all.count, 2)
    }
}
```

---

## Quick Reference

### When to Use Each Pattern

| Scenario | Pattern |
|----------|---------|
| Navigation between screens | Coordinator |
| Shared dependencies | Dependency Container |
| Data access abstraction | Repository |
| Business logic | Service Layer |
| UI state | ViewModel |
| Platform differences | Conditional compilation + protocols |
| Multiple windows | Window Manager + Window Coordinators |
| Background processing | Service Controller / LaunchAgent |

### Testing Priority

1. **Unit test** ViewModels (business logic)
2. **Unit test** Services (domain logic)
3. **Integration test** Repository implementations
4. **UI test** critical user flows only

### Common Pitfalls

- ❌ Singleton services (hard to test)
- ❌ ViewControllers with business logic
- ❌ Circular dependencies
- ❌ Force-unwrapping in production code
- ❌ Blocking main thread with sync I/O
- ✅ Protocol-based dependencies
- ✅ ViewModels own business logic
- ✅ Unidirectional data flow
- ✅ Proper error handling
- ✅ Async/await for I/O
