import Foundation

final class ThemeManager {
    // MARK: - Properties

    // The targets' associated storages of theme handlers.
    private var targetActionStorages = NSHashTable<TargetActionStorage>.weakObjects()

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

    /// Registers a theme handler which is in the form of *target-action*.
    ///
    /// - Parameters:
    ///   - target: The target object.
    ///   - action: The action method.
    ///
    /// - Warning: It also initially executes the registered action!
    public func register<T: AnyObject>(target: T, action: @escaping (T) -> (MyTheme) -> ()) {
        var storage: TargetActionStorage
        if let s = TargetActionStorage.get(for: target) {
            storage = s
        } else {
            storage = TargetActionStorage.setup(for: target)
            targetActionStorages.add(storage)
        }

        storage.register(target: target, action: action, initialTheme: theme)
    }

    // Embodies the notification mechanism, i.e., it iterates through all the
    // targets' associated storages and performs execution of their registered
    // theme handlers in the order of their registration (on per-target basis).
    private func apply() {
        targetActionStorages.allObjects.forEach {
            $0.applyTheme(theme)
        }
    }
}

