import UIKit

class DemoViewController: UIViewController {
    @IBOutlet weak var highlightedLabel: HighlightedLabel!

    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!

    @IBAction func modeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: isDarkMode = false
        case 1: isDarkMode = true
        default: break
        }
    }

    var isDarkMode: Bool = false {
        didSet {
            ThemeManager.shared.theme = isDarkMode
                ? .dark
                : .light
            modeSegmentedControl.selectedSegmentIndex = isDarkMode
                ? 1
                : 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Subscribe to theme notifications
        ThemeManager.shared.register(self)

        updateMode()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard UIApplication.shared.applicationState == .inactive else {
            return
        }

        updateMode()
    }

    func updateMode() {
        if #available(iOS 13.0, *) {
            isDarkMode = traitCollection.userInterfaceStyle == .dark
        }
    }
}

extension DemoViewController: Themable {
    /// Handles theme notifications receiving a new theme.
    func applyTheme(_ theme: MyTheme) {
        view.backgroundColor = theme.settings.appBgColor
    }
}

