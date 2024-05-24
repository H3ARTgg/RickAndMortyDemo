import UIKit

extension UIView {
    func cornerRadius(_ value: CGFloat, maskedCorners: CACornerMask? = nil) {
        layer.cornerRadius = value
        layer.masksToBounds = true
        if let maskedCorners {
            layer.maskedCorners = maskedCorners
        }
    }
}
