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

// MARK: - ActivityIndicator
extension UIViewController {
    func showActivityIndicator(_ indicator: UIActivityIndicatorView) {
        let window = UIApplication.keyWindow
        window?.isUserInteractionEnabled = false
        configureActivityIndicator(indicator)
        indicator.startAnimating()
    }
    
    func removeActivityIndicator(_ indicator: UIActivityIndicatorView) {
        let window = UIApplication.keyWindow
        window?.isUserInteractionEnabled = true
        
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
    
    private func configureActivityIndicator(_ indicator: UIActivityIndicatorView) {
        indicator.color = .rmWhite
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
