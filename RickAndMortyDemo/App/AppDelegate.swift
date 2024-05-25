import UIKit
import SnapKit

// MARK: - RouterDelegate Protocol
protocol RouterDelegate: AnyObject {
    func setRootViewController(_ viewController: Presentable?)
}

// MARK: - AppDelegate
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private lazy var router: Routable = Router(routerDelegate: self)
    private lazy var appCoordinator = coordinatorFactory.makeAppCoordinator(router: router)
    private let coordinatorFactory: CoordinatorsFactoryProtocol = CoordinatorFactory()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        appCoordinator.startFlow()
        return true
    }
}

// MARK: - Router Delegate
extension AppDelegate: RouterDelegate {
    func setRootViewController(_ viewController: Presentable?) {
        window?.rootViewController = viewController?.toPresent()
    }
}

