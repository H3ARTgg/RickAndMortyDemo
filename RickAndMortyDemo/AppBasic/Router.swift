import UIKit

// MARK: - Presentable
protocol Presentable: AnyObject {
    func toPresent() -> UIViewController?
}

// MARK: - RouterDelegate Protocol
protocol RouterDelegate: AnyObject {
    func setRootViewController(_ viewController: Presentable?)
}

// MARK: - Routable Protocol
protocol Routable: AnyObject {
    func setRootViewController(viewController: Presentable)
    
    func push(_ module: Presentable?, to navController: UINavigationController)
    func push(_ module: Presentable?, to navController: UINavigationController, animated: Bool)
    
    func popToRoot(_ module: Presentable?)
}

// MARK: - Router
final class Router: NSObject {
    private let delegate: RouterDelegate?
    
    init(routerDelegate: RouterDelegate) {
        self.delegate = routerDelegate
    }
}

// MARK: - Router Routable
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
    
    func popToRoot(_ module: Presentable?) {
        guard let controller = module?.toPresent() else { return }
        controller.navigationController?.popToRootViewController(animated: true)
    }
}
