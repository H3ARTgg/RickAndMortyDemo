// MARK: - CoordinatorsFactoryProtocol
protocol CoordinatorsFactoryProtocol: AnyObject {
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput
    func makeCharactersListCoordinator(router: Routable, navigationController: CustomNavigationController) -> Coordinatable
    func makeFavoritesCoordinator(router: Routable, navigationController: CustomNavigationController) -> Coordinatable
}

// MARK: - CoordinatorFactory
final class CoordinatorFactory {
    private let modulesFactory: ModulesFactoryProtocol
    
    init(modulesFactory: ModulesFactoryProtocol) {
        self.modulesFactory = modulesFactory
    }
}

// MARK: - CoordinatorFactory CoordinatorsFactoryProtocol
extension CoordinatorFactory: CoordinatorsFactoryProtocol {
    func makeAppCoordinator(router: Routable) -> AppCoordinatorOutput & Coordinatable {
        return AppCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router)
    }
    
    func makeCharactersListCoordinator(router: Routable, navigationController: CustomNavigationController) -> Coordinatable {
        return CharactersCoordinator(modulesFactory: modulesFactory, router: router, navigationController: navigationController)
    }
    
    func makeFavoritesCoordinator(router: Routable, navigationController: CustomNavigationController) -> Coordinatable {
        return FavoritesCoordinator(modulesFactory: modulesFactory, router: router, navigationController: navigationController)
    }
}
