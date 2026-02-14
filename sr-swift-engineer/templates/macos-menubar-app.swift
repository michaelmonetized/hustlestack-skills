// TEMPLATE: macOS Menu Bar App
// A minimal, production-ready menu bar application scaffold
//
// Usage: Copy these files to start a new menu bar app project

// ============================================================================
// FILE: AppDelegate.swift
// ============================================================================

import AppKit

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItemController: StatusItemController?
    private var popoverController: PopoverController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon (menu bar only)
        NSApp.setActivationPolicy(.accessory)
        
        setupStatusItem()
        registerDefaults()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    private func setupStatusItem() {
        popoverController = PopoverController()
        statusItemController = StatusItemController(popoverController: popoverController!)
    }
    
    private func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            "launchAtLogin": false
        ])
    }
}

// ============================================================================
// FILE: StatusItemController.swift
// ============================================================================

import AppKit

final class StatusItemController {
    
    private var statusItem: NSStatusItem?
    private let popoverController: PopoverController
    private let menu = NSMenu()
    
    init(popoverController: PopoverController) {
        self.popoverController = popoverController
        setupStatusItem()
        setupMenu()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            // Use SF Symbol or custom icon
            button.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: "My App")
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupMenu() {
        menu.addItem(withTitle: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        for item in menu.items {
            item.target = self
        }
    }
    
    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            togglePopover()
        }
    }
    
    private func showMenu() {
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    private func togglePopover() {
        if popoverController.isShown {
            popoverController.close()
        } else if let button = statusItem?.button {
            popoverController.show(relativeTo: button.bounds, of: button)
        }
    }
    
    @objc private func showPreferences() {
        PreferencesWindowController.shared.showWindow()
    }
}

// ============================================================================
// FILE: PopoverController.swift
// ============================================================================

import AppKit

final class PopoverController: NSObject {
    
    private let popover: NSPopover
    private var eventMonitor: Any?
    
    var isShown: Bool {
        popover.isShown
    }
    
    override init() {
        popover = NSPopover()
        super.init()
        
        popover.contentViewController = PopoverViewController()
        popover.behavior = .transient
        popover.delegate = self
    }
    
    func show(relativeTo rect: NSRect, of view: NSView) {
        popover.show(relativeTo: rect, of: view, preferredEdge: .minY)
        startEventMonitor()
    }
    
    func close() {
        popover.performClose(nil)
    }
    
    private func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.close()
        }
    }
    
    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

extension PopoverController: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        stopEventMonitor()
    }
}

// ============================================================================
// FILE: PopoverViewController.swift
// ============================================================================

import AppKit

final class PopoverViewController: NSViewController {
    
    private lazy var stackView: NSStackView = {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 12
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "My Menu Bar App")
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .labelColor
        return label
    }()
    
    private lazy var descriptionLabel: NSTextField = {
        let label = NSTextField(wrappingLabelWithString: "This is your popover content. Customize it to show whatever your app needs.")
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabelColor
        return label
    }()
    
    private lazy var actionButton: NSButton = {
        let button = NSButton(title: "Do Something", target: self, action: #selector(actionTapped))
        button.bezelStyle = .rounded
        button.controlSize = .large
        return button
    }()
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(actionButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    @objc private func actionTapped(_ sender: NSButton) {
        // Handle action
        print("Action tapped!")
    }
}

// ============================================================================
// FILE: PreferencesWindowController.swift
// ============================================================================

import AppKit

final class PreferencesWindowController: NSWindowController {
    
    static let shared = PreferencesWindowController()
    
    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        window.title = "Preferences"
        window.center()
        
        setupTabs()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupTabs() {
        let tabViewController = NSTabViewController()
        tabViewController.tabStyle = .toolbar
        
        // General tab
        let generalVC = GeneralPreferencesViewController()
        generalVC.title = "General"
        let generalItem = NSTabViewItem(viewController: generalVC)
        generalItem.image = NSImage(systemSymbolName: "gear", accessibilityDescription: nil)
        tabViewController.addTabViewItem(generalItem)
        
        window?.contentViewController = tabViewController
    }
    
    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// ============================================================================
// FILE: GeneralPreferencesViewController.swift
// ============================================================================

import AppKit
import ServiceManagement

final class GeneralPreferencesViewController: NSViewController {
    
    private lazy var launchAtLoginCheckbox: NSButton = {
        let checkbox = NSButton(checkboxWithTitle: "Launch at login", target: self, action: #selector(launchAtLoginChanged))
        checkbox.state = UserDefaults.standard.bool(forKey: "launchAtLogin") ? .on : .off
        return checkbox
    }()
    
    override func loadView() {
        view = NSView()
        view.setFrameSize(NSSize(width: 400, height: 200))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        launchAtLoginCheckbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(launchAtLoginCheckbox)
        
        NSLayoutConstraint.activate([
            launchAtLoginCheckbox.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            launchAtLoginCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    @objc private func launchAtLoginChanged(_ sender: NSButton) {
        let enabled = sender.state == .on
        UserDefaults.standard.set(enabled, forKey: "launchAtLogin")
        
        // macOS 13+
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update login item: \(error)")
            }
        }
    }
}

// ============================================================================
// FILE: Info.plist additions
// ============================================================================
/*
Add to Info.plist:

<key>LSUIElement</key>
<true/>

This hides the app from the Dock and app switcher.
Alternatively, set via NSApp.setActivationPolicy(.accessory) in AppDelegate.
*/

// ============================================================================
// FILE: MyApp.entitlements
// ============================================================================
/*
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
</dict>
</plist>
*/
