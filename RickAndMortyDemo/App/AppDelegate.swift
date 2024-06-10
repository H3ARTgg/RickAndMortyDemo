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
    private let coordinatorFactory: CoordinatorsFactoryProtocol = {
        let networkService = DefaultNetworkClient()
        let networkManager = NetworkManager(networkService: networkService)
        let storage = RealmStorage()
        let modulesFactory = ModulesFactory(networkManager: networkManager, storage: storage)
        let coordinatorFactory = CoordinatorFactory(modulesFactory: modulesFactory)
        return coordinatorFactory
    }()
    private lazy var router: Routable = Router(routerDelegate: self)
    private lazy var appCoordinator = coordinatorFactory.makeAppCoordinator(router: router)
    
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

