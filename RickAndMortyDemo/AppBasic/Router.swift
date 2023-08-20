import UIKit

protocol Routable: AnyObject {
    func setRootViewController(viewController: Presentable)
    
    func push(_ module: Presentable?, to navController: UINavigationController)
    func push(_ module: Presentable?, to navController: UINavigationController, animated: Bool)
}

final class Router: NSObject {
    weak var delegate: RouterDelegate?
    private var presentingViewController: Presentable?
    
    init(routerDelegate: RouterDelegate) {
        self.delegate = routerDelegate
    }
}

extension Router: Routable {
    func setRootViewController(viewController: Presentable) {
        delegate?.setRootViewController(viewController)
    }
    
    func push(_ module: Presentable?, to navController: UINavigationController) {
        push(module, to: navController, animated: true)
    }
    
    func push(_ module: Presentable?, to navController: UINavigationController, animated: Bool) {
        guard let controller = module?.toPresent() else { return }
        navController.pushViewController(controller, animated: animated)
    }
}

