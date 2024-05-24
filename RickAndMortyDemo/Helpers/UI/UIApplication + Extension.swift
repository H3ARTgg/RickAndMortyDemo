import UIKit

public extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    class func getTopVC(base: UIViewController? =
                        UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopVC(base: nav.visibleViewController)
        }
        
        if let presented = base?.presentedViewController {
            return getTopVC(base: presented)
        }
        return base
    }
}
