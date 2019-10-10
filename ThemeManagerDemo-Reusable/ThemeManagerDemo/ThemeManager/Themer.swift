import UIKit
import Themer

// Integration point.

// Establish the theme manager.
extension Themer where Theme == MyTheme {
    private static var instance: Themer?
    static var shared: Themer {
        if instance == nil {
            instance = Themer(defaultTheme: .light)
        }
        return instance!
    }
}
