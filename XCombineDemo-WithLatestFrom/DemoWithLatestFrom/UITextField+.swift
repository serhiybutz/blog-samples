import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default
            .publisher(
                for: UITextField.textDidChangeNotification,
                object: self)
            .map(\.object)
            .map { $0 as! UITextField }
            .map(\.text)
            .eraseToAnyPublisher()
    }
}
