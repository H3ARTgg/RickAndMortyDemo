import UIKit

protocol Routable: AnyObject {
    func setRootViewController(viewController: Presentable)
    
    func push(_ module: Presentable?, to navController: UINavigationController)
    func push(_ module: Presentable?, to navController: UINavigationController, animated: Bool)
    
    func dismissModule(_ module: Presentable?)
    
    func popToRoot(_ module: Presentable?)
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
    
    func present(_ module: Presentable?) {
        present(module, animated: true, presentationStyle: .automatic)
    }
    
    func present(_ module: Presentable?, animated: Bool) {
        present(module, animated: animated, presentationStyle: .automatic)
    }
    
    func present(_ module: Presentable?, animated: Bool, presentationStyle: UIModalPresentationStyle) {
        guard let controller = module?.toPresent() else { return }
        controller.modalPresentationStyle = presentationStyle
        presentingViewController?.toPresent()?.present(controller, animated: animated, completion: nil)
        presentingViewController = controller
    }
    
    func dismissModule(_ module: Presentable?) {
        guard let controller = module?.toPresent() else { return }
        presentingViewController = module?.toPresent()?.presentingViewController
        controller.dismiss(animated: true, completion: nil)
    }
    
    func popToRoot(_ module: Presentable?) {
        guard let controller = module?.toPresent() else { return }
        presentingViewController = module?.toPresent()?.presentingViewController
        controller.navigationController?.popToRootViewController(animated: true)
    }
}

