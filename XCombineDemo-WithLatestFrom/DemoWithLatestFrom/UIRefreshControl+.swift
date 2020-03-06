import UIKit
import Combine

extension UIRefreshControl {
    private static var beginRefreshingAssociatedKey = "BeginRefreshingPublisher"

    private typealias BeginRefreshingPublisher = PassthroughSubject<Void, Never>

    private var internalBeginRefreshingPublisher: BeginRefreshingPublisher {
        var publisher = objc_getAssociatedObject(
            self,
            &UIRefreshControl.beginRefreshingAssociatedKey)
            .map { $0 as! BeginRefreshingPublisher }

        if publisher == nil {
            if Thread.current.isMainThread {
                instantiate(&publisher)
            } else {
                DispatchQueue.main.sync {
                    instantiate(&publisher)
                }
            }
        }
        return publisher!
    }

    private func instantiate(_ publisher: inout BeginRefreshingPublisher?) {
        guard publisher == nil else { return; }  // Double-Checked Locking
        publisher = BeginRefreshingPublisher()
        objc_setAssociatedObject(
            self,
            &UIRefreshControl.beginRefreshingAssociatedKey,
            publisher!,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.addTarget(
            self,
            action: #selector(handleValueChanged), for: .valueChanged)
    }

    @objc
    private func handleValueChanged() {
        internalBeginRefreshingPublisher.send()
    }

    var beginRefreshingPublisher: AnyPublisher<Void, Never> {
        internalBeginRefreshingPublisher.eraseToAnyPublisher()
    }
}
