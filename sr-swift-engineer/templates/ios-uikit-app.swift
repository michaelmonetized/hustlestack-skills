// TEMPLATE: iOS UIKit App with Coordinator Pattern
// A modern, production-ready iOS app scaffold using UIKit
//
// Usage: Copy these files to start a new iOS app project

// ============================================================================
// FILE: AppDelegate.swift
// ============================================================================

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// ============================================================================
// FILE: SceneDelegate.swift
// ============================================================================

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
        
        window.makeKeyAndVisible()
    }
}

// ============================================================================
// FILE: Coordinators/Coordinator.swift
// ============================================================================

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    
    func start()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

// ============================================================================
// FILE: Coordinators/AppCoordinator.swift
// ============================================================================

import UIKit

final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        
        configureNavigationBar()
    }
    
    func start() {
        window.rootViewController = navigationController
        showHome()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    private func showHome() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator.parentCoordinator = self
        addChild(homeCoordinator)
        homeCoordinator.start()
    }
    
    func childDidFinish(_ coordinator: Coordinator) {
        removeChild(coordinator)
    }
}

// ============================================================================
// FILE: Coordinators/HomeCoordinator.swift
// ============================================================================

import UIKit

final class HomeCoordinator: Coordinator {
    
    weak var parentCoordinator: AppCoordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showDetail(for item: Item) {
        let detailCoordinator = DetailCoordinator(
            navigationController: navigationController,
            item: item
        )
        detailCoordinator.parentCoordinator = self
        addChild(detailCoordinator)
        detailCoordinator.start()
    }
    
    func showSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.coordinator = self
        
        let nav = UINavigationController(rootViewController: settingsVC)
        navigationController.present(nav, animated: true)
    }
    
    func childDidFinish(_ coordinator: Coordinator) {
        removeChild(coordinator)
    }
}

// ============================================================================
// FILE: Coordinators/DetailCoordinator.swift
// ============================================================================

import UIKit

final class DetailCoordinator: Coordinator {
    
    weak var parentCoordinator: HomeCoordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    private let item: Item
    
    init(navigationController: UINavigationController, item: Item) {
        self.navigationController = navigationController
        self.item = item
    }
    
    func start() {
        let viewModel = DetailViewModel(item: item)
        let viewController = DetailViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        parentCoordinator?.childDidFinish(self)
    }
}

// ============================================================================
// FILE: Models/Item.swift
// ============================================================================

import Foundation

struct Item: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    let iconName: String
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String? = nil,
        iconName: String = "star.fill",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.createdAt = createdAt
    }
}

// ============================================================================
// FILE: ViewModels/HomeViewModel.swift
// ============================================================================

import Foundation

@MainActor
final class HomeViewModel {
    
    // MARK: - Properties
    
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    
    // MARK: - Callbacks
    
    var onDataChanged: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    
    // MARK: - Dependencies
    
    private let service: DataServiceProtocol
    
    // MARK: - Initialization
    
    init(service: DataServiceProtocol = DataService.shared) {
        self.service = service
    }
    
    // MARK: - Actions
    
    func loadData() async {
        isLoading = true
        onLoadingChanged?(true)
        
        do {
            items = try await service.fetchItems()
            onDataChanged?()
        } catch {
            onError?(error)
        }
        
        isLoading = false
        onLoadingChanged?(false)
    }
    
    func addItem(title: String) async {
        let item = Item(title: title)
        
        do {
            try await service.save(item)
            items.append(item)
            onDataChanged?()
        } catch {
            onError?(error)
        }
    }
    
    func deleteItem(at index: Int) async {
        guard index >= 0, index < items.count else { return }
        let item = items[index]
        
        do {
            try await service.delete(item)
            items.remove(at: index)
            onDataChanged?()
        } catch {
            onError?(error)
        }
    }
    
    func item(at index: Int) -> Item? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }
}

// ============================================================================
// FILE: ViewModels/DetailViewModel.swift
// ============================================================================

import Foundation

@MainActor
final class DetailViewModel {
    
    let item: Item
    
    init(item: Item) {
        self.item = item
    }
}

// ============================================================================
// FILE: Views/HomeViewController.swift
// ============================================================================

import UIKit

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    weak var coordinator: HomeCoordinator?
    
    // MARK: - Views
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var dataSource = makeDataSource()
    
    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return rc
    }()
    
    // MARK: - Initialization
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupNavigation()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(collectionView)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigation() {
        title = "Items"
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in
                self?.showAddItemAlert()
            }
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            primaryAction: UIAction { [weak self] _ in
                self?.coordinator?.showSettings()
            }
        )
    }
    
    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] in
            self?.applySnapshot()
            self?.refreshControl.endRefreshing()
        }
        
        viewModel.onError = { [weak self] error in
            self?.showError(error)
            self?.refreshControl.endRefreshing()
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            if !isLoading {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Collection View
    
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            self?.makeSwipeActions(for: indexPath)
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.secondaryText = item.subtitle
            content.image = UIImage(systemName: item.iconName)
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
        
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { cv, indexPath, item in
            cv.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            Task {
                await self?.viewModel.deleteItem(at: indexPath.row)
                completion(true)
            }
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Actions
    
    @objc private func refresh() {
        Task {
            await viewModel.loadData()
        }
    }
    
    private func showAddItemAlert() {
        let alert = UIAlertController(title: "New Item", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Item title"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] _ in
            guard let title = alert?.textFields?.first?.text, !title.isEmpty else { return }
            Task {
                await self?.viewModel.addItem(title: title)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = viewModel.item(at: indexPath.row) else { return }
        coordinator?.showDetail(for: item)
    }
}

// MARK: - Section

extension HomeViewController {
    enum Section {
        case main
    }
}

// ============================================================================
// FILE: Views/DetailViewController.swift
// ============================================================================

import UIKit

final class DetailViewController: UIViewController {
    
    private let viewModel: DetailViewModel
    weak var coordinator: DetailCoordinator?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configure()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    private func configure() {
        title = "Detail"
        navigationItem.largeTitleDisplayMode = .never
        
        titleLabel.text = viewModel.item.title
        subtitleLabel.text = viewModel.item.subtitle ?? "No description"
    }
}

// ============================================================================
// FILE: Views/SettingsViewController.swift
// ============================================================================

import UIKit

final class SettingsViewController: UIViewController {
    
    weak var coordinator: HomeCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        title = "Settings"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
    }
}

// ============================================================================
// FILE: Services/DataService.swift
// ============================================================================

import Foundation

protocol DataServiceProtocol: Sendable {
    func fetchItems() async throws -> [Item]
    func save(_ item: Item) async throws
    func delete(_ item: Item) async throws
}

actor DataService: DataServiceProtocol {
    
    static let shared = DataService()
    
    private var items: [Item] = []
    
    private init() {
        // Seed with sample data
        items = [
            Item(title: "First Item", subtitle: "This is the first item"),
            Item(title: "Second Item", subtitle: "This is the second item"),
            Item(title: "Third Item", subtitle: "This is the third item")
        ]
    }
    
    func fetchItems() async throws -> [Item] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        return items
    }
    
    func save(_ item: Item) async throws {
        items.append(item)
    }
    
    func delete(_ item: Item) async throws {
        items.removeAll { $0.id == item.id }
    }
}
