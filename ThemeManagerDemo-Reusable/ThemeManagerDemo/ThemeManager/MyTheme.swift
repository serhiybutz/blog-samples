import UIKit
import Themer

// A theme enum, that describes available themes
enum MyTheme: ThemeProtocol {
    case light
    case dark
    var settings: MyThemeSettings {
        switch self {
        case .light: return MyThemeSettings.lightTheme
        case .dark: return MyThemeSettings.darkTheme
        }
    }
}
