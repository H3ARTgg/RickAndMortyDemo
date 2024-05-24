import UIKit

// MARK: - Presentable
protocol Presentable: AnyObject {
    func toPresent() -> UIViewController?
}

extension UIViewController: Presentable {
    func toPresent() -> UIViewController? {
        return self
    }
}
