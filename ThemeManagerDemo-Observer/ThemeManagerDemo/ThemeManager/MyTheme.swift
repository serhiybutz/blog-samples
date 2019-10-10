import UIKit

// A theme enum, that describes available themes
@objc enum MyTheme: Int {
    case light
    case dark
    var settings: MyThemeSettings {
        switch self {
            case .light: return MyThemeSettings.lightTheme
            case .dark: return MyThemeSettings.darkTheme
        }
    }
}
