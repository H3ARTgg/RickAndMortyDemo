// MARK: - AppCoordinatorOutput Protocol
protocol AppCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

// MARK: - AppCoordinator
final class AppCoordinator: BaseCoordinator, Coordinatable, AppCoordinatorOutput {
    var finishFlow: (() -> Void)?
    
    private let coordinatorsFactory: CoordinatorsFactoryProtocol
    private let modulesFactory: ModulesFactoryProtocol
    private let router: Routable
    private let navigationControllers: [CustomNavigationController] = [CustomNavigationController(), CustomNavigationController()]
    private let tabBar = CustomTabBarController()
    
    // MARK: - Init
    init(coordinatorsFactory: CoordinatorsFactoryProtocol, modulesFactory: ModulesFactoryProtocol, router: Routable) {
        self.coordinatorsFactory = coordinatorsFactory
        self.modulesFactory = modulesFactory
        self.router = router
    }
    
    func startFlow() {
        tabBar.viewControllers = navigationControllers
        routeToCustomTabBar()
        createCharactersListFlow(navigationController: navigationControllers[0])
        createFavoritesFlow(navigationController: navigationControllers[1])
    }
}

// MARK: - AppCoordinator Extension
private extension AppCoordinator {
    func routeToCustomTabBar() {
        router.setRootViewController(viewController: tabBar)
    }
    
    func createCharactersListFlow(navigationController: CustomNavigationController) {
        let charactersListCoordinator = coordinatorsFactory.makeCharactersListCoordinator(router: router, navigationController: navigationController)
        addDependency(charactersListCoordinator)
        charactersListCoordinator.startFlow()
    }
    
    func createFavoritesFlow(navigationController: CustomNavigationController) {
        let favoritesCoordinator = coordinatorsFactory.makeFavoritesCoordinator(router: router, navigationController: navigationController)
        addDependency(favoritesCoordinator)
        favoritesCoordinator.startFlow()
    }
}
