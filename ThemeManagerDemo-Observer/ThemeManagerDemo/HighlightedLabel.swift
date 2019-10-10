import UIKit

/// A highlighted label class.
class HighlightedLabel: UILabel {
    override func didMoveToWindow() {
        // Subscribe to theme notifications
        ThemeManager.shared.register(self)
        super.didMoveToWindow()
    }
}

extension HighlightedLabel: Themable {
    /// Handles theme notifications receiving a new theme.
    func applyTheme(_ theme: MyTheme) {
        textColor = theme.settings.textColor
        backgroundColor = theme.settings.highlightedBgColor
        switch theme {
        case .light:
            text = "Light Mode"
        case .dark:
            text = "Dark Mode"
        }
        sizeToFit()
    }
}
