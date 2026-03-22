import AppKit
import ServiceManagement

// MARK: - UserDefaults helpers for NSColor

extension UserDefaults {
    func nsColor(forKey key: String) -> NSColor? {
        guard let data = data(forKey: key) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    }

    func set(nsColor: NSColor, forKey key: String) {
        let data = try? NSKeyedArchiver.archivedData(
            withRootObject: nsColor, requiringSecureCoding: false)
        set(data, forKey: key)
    }
}

// MARK: - Preferences

/// Central store for all user-configurable settings.
/// Changes are persisted immediately to UserDefaults and broadcast via
/// `Preferences.didChangeNotification` so AppKit subscribers (GridView, AppDelegate)
/// can react without requiring Combine/SwiftUI.
final class Preferences: ObservableObject {

    static let shared = Preferences()

    // Posted on the default NotificationCenter after any property changes.
    static let didChangeNotification = Notification.Name("SpacesGridPreferencesDidChange")

    private let ud = UserDefaults.standard

    // MARK: - Appearance

    @Published var activeColor: NSColor {
        didSet { ud.set(nsColor: activeColor, forKey: Keys.activeColor); emit() }
    }
    @Published var occupiedColor: NSColor {
        didSet { ud.set(nsColor: occupiedColor, forKey: Keys.occupiedColor); emit() }
    }
    @Published var emptyBorderColor: NSColor {
        didSet { ud.set(nsColor: emptyBorderColor, forKey: Keys.emptyBorderColor); emit() }
    }
    @Published var borderWidth: Double {
        didSet { ud.set(borderWidth, forKey: Keys.borderWidth); emit() }
    }
    @Published var cornerRadius: Double {
        didSet { ud.set(cornerRadius, forKey: Keys.cornerRadius); emit() }
    }

    // MARK: - Grid

    @Published var columns: Int {
        didSet { ud.set(columns, forKey: Keys.columns); emit() }
    }
    @Published var rows: Int {
        didSet { ud.set(rows, forKey: Keys.rows); emit() }
    }
    @Published var cellWidth: Double {
        didSet { ud.set(cellWidth, forKey: Keys.cellWidth); emit() }
    }
    @Published var cellHeight: Double {
        didSet { ud.set(cellHeight, forKey: Keys.cellHeight); emit() }
    }
    @Published var cellGap: Double {
        didSet { ud.set(cellGap, forKey: Keys.cellGap); emit() }
    }

    // MARK: - Behaviour

    @Published var refreshInterval: Double {
        didSet { ud.set(refreshInterval, forKey: Keys.refreshInterval); emit() }
    }
    @Published var showWindowIndicators: Bool {
        didSet { ud.set(showWindowIndicators, forKey: Keys.showWindowIndicators); emit() }
    }
    @Published var showFullscreenBadge: Bool {
        didSet { ud.set(showFullscreenBadge, forKey: Keys.showFullscreenBadge); emit() }
    }

    // Launch-at-login reads/writes SMAppService directly; not stored in UserDefaults.
    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            if newValue {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }

    // MARK: - Init

    private init() {
        activeColor       = ud.nsColor(forKey: Keys.activeColor)       ?? .controlAccentColor
        occupiedColor     = ud.nsColor(forKey: Keys.occupiedColor)     ?? NSColor.white.withAlphaComponent(0.55)
        emptyBorderColor  = ud.nsColor(forKey: Keys.emptyBorderColor)  ?? NSColor.white.withAlphaComponent(0.22)
        borderWidth       = ud.object(forKey: Keys.borderWidth)   as? Double ?? 0.75
        cornerRadius      = ud.object(forKey: Keys.cornerRadius)  as? Double ?? 1.5
        columns           = ud.object(forKey: Keys.columns)       as? Int    ?? 5
        rows              = ud.object(forKey: Keys.rows)          as? Int    ?? 2
        cellWidth         = ud.object(forKey: Keys.cellWidth)     as? Double ?? 9
        cellHeight        = ud.object(forKey: Keys.cellHeight)    as? Double ?? 6
        cellGap           = ud.object(forKey: Keys.cellGap)       as? Double ?? 1.5
        refreshInterval      = ud.object(forKey: Keys.refreshInterval)      as? Double ?? 2.0
        showWindowIndicators = ud.object(forKey: Keys.showWindowIndicators) as? Bool  ?? true
        showFullscreenBadge  = ud.object(forKey: Keys.showFullscreenBadge)  as? Bool  ?? true
    }

    // MARK: - Reset

    func resetToDefaults() {
        activeColor         = .controlAccentColor
        occupiedColor       = NSColor.white.withAlphaComponent(0.55)
        emptyBorderColor    = NSColor.white.withAlphaComponent(0.22)
        borderWidth         = 0.75
        cornerRadius        = 1.5
        columns             = 5
        rows                = 2
        cellWidth           = 9
        cellHeight          = 6
        cellGap             = 1.5
        refreshInterval      = 2.0
        showWindowIndicators  = true
        showFullscreenBadge  = true
    }

    // MARK: - Internal

    private func emit() {
        NotificationCenter.default.post(name: Preferences.didChangeNotification, object: self)
    }

    private enum Keys {
        static let activeColor          = "activeColor"
        static let occupiedColor        = "occupiedColor"
        static let emptyBorderColor     = "emptyBorderColor"
        static let borderWidth          = "borderWidth"
        static let cornerRadius         = "cornerRadius"
        static let columns              = "columns"
        static let rows                 = "rows"
        static let cellWidth            = "cellWidth"
        static let cellHeight           = "cellHeight"
        static let cellGap              = "cellGap"
        static let refreshInterval      = "refreshInterval"
        static let showWindowIndicators  = "showWindowIndicators"
        static let showFullscreenBadge  = "showFullscreenBadge"
    }
}
