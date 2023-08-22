protocol AppCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class AppCoordinator: BaseCoordinator, Coordinatable, AppCoordinatorOutput {
    var finishFlow: (() -> Void)?
    
    private var coordinatorsFactory: CoordinatorsFactoryProtocol
    private var modulesFactory: ModulesFactoryProtocol
    private var router: Routable
    private let charactersNavCon = CharactersListNavCon()
    
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
