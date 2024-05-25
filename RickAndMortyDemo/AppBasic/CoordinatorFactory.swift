// MARK: - CoordinatorsFactoryProtocol
protocol CoordinatorsFactoryProtocol: AnyObject {
    func makeAppCoordinator(router: Routable) -> Coordinatable & AppCoordinatorOutput
    func makeCharactersListCoordinator(router: Routable, navCon: CharactersListNavCon) -> Coordinatable
}

// MARK: - CoordinatorFactory
final class CoordinatorFactory {
    private let modulesFactory: ModulesFactoryProtocol = ModulesFactory()
}

// MARK: - CoordinatorFactory CoordinatorsFactoryProtocol
extension CoordinatorFactory: CoordinatorsFactoryProtocol {
    func makeAppCoordinator(router: Routable) -> AppCoordinatorOutput & Coordinatable {
        return AppCoordinator(coordinatorsFactory: self, modulesFactory: modulesFactory, router: router)
    }
    
    func makeCharactersListCoordinator(router: Routable, navCon: CharactersListNavCon) -> Coordinatable {
        return CharactersCoordinator(modulesFactory: modulesFactory, router: router, navCon: navCon)
    }
}
