import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - State

    private var statusItem: NSStatusItem!
    private var gridView: GridView!
    private let spacesManager = SpacesManager()
    private var pollTimer: Timer?

    // MARK: - App lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        setupStatusItem()
        setupObservers()
        startPolling()
    }

    func applicationWillTerminate(_ notification: Notification) {
        pollTimer?.invalidate()
    }

    // MARK: - Setup

    private func setupStatusItem() {
        let size  = GridView.idealSize()
        let padX: CGFloat = 5
        let itemW = size.width + padX * 2

        statusItem = NSStatusBar.system.statusItem(withLength: itemW)

        guard let button = statusItem.button else { return }

        let gridY = (22 - size.height) / 2
        gridView = GridView(frame: NSRect(x: padX, y: gridY, width: size.width, height: size.height))
        gridView.spacesManager = spacesManager
        gridView.autoresizingMask = [.minYMargin, .maxYMargin]
        button.addSubview(gridView)

        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func setupObservers() {
        // Redraw when the user switches spaces.
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(refresh),
            name: NSWorkspace.activeSpaceDidChangeNotification, object: nil
        )
        // Redraw when system appearance (dark/light) changes.
        DistributedNotificationCenter.default().addObserver(
            self, selector: #selector(refresh),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil
        )
        // Re-layout the status item when any preference changes.
        NotificationCenter.default.addObserver(
            self, selector: #selector(preferencesChanged),
            name: Preferences.didChangeNotification, object: nil
        )
    }

    private func startPolling() {
        scheduleTimer(interval: Preferences.shared.refreshInterval)
    }

    private func scheduleTimer(interval: TimeInterval) {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    // MARK: - Reactions

    @objc private func refresh() {
        DispatchQueue.main.async { [weak self] in
            self?.gridView.needsDisplay = true
        }
    }

    /// Called whenever any Preference changes. Resizes the status item if the
    /// grid geometry changed, and restarts the poll timer if the interval changed.
    @objc private func preferencesChanged() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let prefs = Preferences.shared
            let size  = GridView.idealSize()
            let padX: CGFloat = 5
            let itemW = size.width + padX * 2

            statusItem.length = itemW

            if statusItem.button != nil {
                let gridY = (22 - size.height) / 2
                gridView.frame = NSRect(x: padX, y: gridY, width: size.width, height: size.height)
            }

            scheduleTimer(interval: prefs.refreshInterval)
            gridView.needsDisplay = true
        }
    }

    // MARK: - Menu

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            showMenu()
        }
        // Left-click is intentionally a no-op; the widget is for display only.
    }

    private func showMenu() {
        let menu = NSMenu()

        let prefsItem = NSMenuItem(
            title: "Preferences…",
            action: #selector(openPreferences),
            keyEquivalent: ","
        )
        prefsItem.target = self
        menu.addItem(prefsItem)

        menu.addItem(.separator())

        menu.addItem(
            NSMenuItem(title: "Quit SpacesGrid",
                       action: #selector(NSApplication.terminate(_:)),
                       keyEquivalent: "q")
        )

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        // Clear so the next left-click does not re-open the menu.
        statusItem.menu = nil
    }

    @objc private func openPreferences() {
        PreferencesWindowController.shared.show()
    }
}
