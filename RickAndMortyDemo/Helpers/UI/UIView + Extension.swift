import UIKit

extension UIView {
    func cornerRadius(_ value: CGFloat) {
        layer.cornerRadius = value
        layer.masksToBounds = true
    }
}
