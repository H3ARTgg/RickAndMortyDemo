import UIKit

extension UIFont {
    enum Gilroy: String {
        case bold = "Gilroy-Bold"
        case medium = "Gilroy-Medium"
    }
    
    static func setGilroy(_ size: CGFloat, type: Gilroy = .medium) -> UIFont {
        UIFont(name: type.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
