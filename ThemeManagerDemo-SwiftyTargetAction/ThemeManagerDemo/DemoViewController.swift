import UIKit

class DemoViewController: UIViewController {
    @IBOutlet weak var highlightedLabel: UILabel!

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

        // Subscribe this instance of UIViewController to theme notifications
        ThemeManager.shared.register(
            target: self,
            action: DemoViewController.applyTheme)

        // Subscribe `highlightedLabel` instance of UILabel to theme notifications
        ThemeManager.shared.register(
            target: highlightedLabel,
            action: UILabel.applyHighlightedLabelTheme)

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

extension DemoViewController {
    /// Handles theme notifications receiving a new theme.
    fileprivate func applyTheme(_ theme: MyTheme) {
        view.backgroundColor = theme.settings.appBgColor
    }
}

extension UILabel {
    /// Handles theme notifications receiving a new theme.
    fileprivate func applyHighlightedLabelTheme(_ theme: MyTheme) {
        switch theme {
        case .light:
            text = "Light Mode"
        case .dark:
            text = "Dark Mode"
        }
        textColor = theme.settings.textColor
        backgroundColor = theme.settings.highlightedBgColor
        sizeToFit()
    }
}
