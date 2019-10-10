import UIKit

// A theme enum, that describes available themes
enum MyTheme {
    case light
    case dark
    var settings: MyThemeSettings {
        switch self {
        case .light: return .lightTheme
        case .dark: return .darkTheme
        }
    }
}
