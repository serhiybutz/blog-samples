import Foundation

struct AnyTargetActionWrapper<T: AnyObject>: TargetAction {
    weak var target: T?
    let action: (T) -> (MyTheme) -> ()

    func applyTheme(_ theme: MyTheme) -> () {
        if let t = target {
            action(t)(theme)
        }
    }
}
