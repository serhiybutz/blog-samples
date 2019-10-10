import Foundation

final class ThemeManager {
    // MARK: - Properties

    private var themables = NSHashTable<Themable>.weakObjects()

    /// The current theme.
    var theme: MyTheme {
        didSet {
            guard theme != oldValue else { return; }
            apply()
        }
    }

    // MARK: - Lifecycle

    private static var instance: ThemeManager?

    static var shared: ThemeManager {
        if instance == nil {
            instance = ThemeManager(defaultTheme: .light)
        }
        return instance!
    }

    // MARK: - Initialization
    
    /// Creates a theme manager.
    ///
    /// - Parameter defaultTheme: The default theme.
    private init(defaultTheme: MyTheme) {
        self.theme = defaultTheme
    }

    // MARK: - Methods

    /// Registers a themable.
    ///
    /// - Parameters:
    ///   - themable: The registered themable.
    ///
    /// - Warning: It also initially executes the themable's theme handler!
    func register(_ themable: Themable) {
        themables.add(themable)
        themable.applyTheme(theme)
    }

    // Embodies the notification mechanism, i.e., it iterates through all the
    // stored themables and performs their notification.
    private func apply() {
        themables.allObjects.forEach {
            $0.applyTheme(theme)
        }
    }
}
