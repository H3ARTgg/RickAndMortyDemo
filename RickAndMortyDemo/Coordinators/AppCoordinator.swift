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
    private let charactersNavCon = CharactersListNavCon()
    
    // MARK: - Init
    init(coordinatorsFactory: CoordinatorsFactoryProtocol, modulesFactory: ModulesFactoryProtocol, router: Routable) {
        self.coordinatorsFactory = coordinatorsFactory
        self.modulesFactory = modulesFactory
        self.router = router
    }
    
    func startFlow() {
        routeToCharactersListNavController()
        createCharactersListFlow(navCon: charactersNavCon)
    }
}

// MARK: - AppCoordinator Extension
private extension AppCoordinator {
    func routeToCharactersListNavController() {
        router.setRootViewController(viewController: charactersNavCon)
    }
    
    func createCharactersListFlow(navCon: CharactersListNavCon) {
        let charactersListCoordinator = coordinatorsFactory.makeCharactersListCoordinator(router: router, navCon: navCon)
        addDependency(charactersListCoordinator)
        charactersListCoordinator.startFlow()
    }
}
