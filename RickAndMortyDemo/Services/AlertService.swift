import UIKit

final class AlertService {
    static func showAlert(style: UIAlertController.Style,
                          title: String?,
                          message: String?,
                          actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .cancel, handler: nil)],
                          completion: (() -> Swift.Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: style)
            
            for action in actions {
                alert.addAction(action)
            }
            
            if let topVC = UIApplication.getTopVC() {
                if let _ = topVC as? UIAlertController {
                    return
                }
                alert.popoverPresentationController?.sourceView = topVC.view
                alert.popoverPresentationController?.sourceRect = CGRect(x: topVC.view.bounds.midX,
                                                                         y: topVC.view.bounds.midY,
                                                                         width: 0, height: 0)
                alert.popoverPresentationController?.permittedArrowDirections = []
                topVC.present(alert, animated: true, completion: completion)
            }
        }
    }
}
