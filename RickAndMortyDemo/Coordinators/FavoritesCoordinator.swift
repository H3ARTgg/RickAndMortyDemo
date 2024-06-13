import Foundation

// MARK: - FavoritesCoordinator
final class FavoritesCoordinator: BaseCoordinator, Coordinatable {
    var finishFlow: (() -> Void)?
    private let modulesFactory: ModulesFactoryProtocol
    private let router: Routable
    private let navigationController: CustomNavigationController
    
    // MARK: - Init
    init(modulesFactory: ModulesFactoryProtocol, router: Routable, navigationController: CustomNavigationController) {
        self.modulesFactory = modulesFactory
        self.router = router
        self.navigationController = navigationController
    }
    
    func startFlow() {
        routeToFavorites()
    }
}

// MARK: - FavoritesCoordinator Extension
private extension FavoritesCoordinator {
    func routeToFavorites() {
        let module = self.modulesFactory.makeFavoritesView()
        let favoritesView = module.view
        let favoritesCoordination = module.coordination

        // fixing bug where view hasn't load yet and tab item is hidden
        _ = module.view.toPresent()?.view
        
        favoritesCoordination.headForCharacterInfo = { [weak self] (characterModel, imageData) in
            guard let self else { return }
            // routing to CharacterInfo
            routeToCharacrerInfo(character: characterModel, imageData: imageData)
        }
        
        router.push(favoritesView, to: navigationController)
    }
    
    func routeToCharacrerInfo(character: CharacterModel, imageData: Data) {
        let charInfoModule = self.modulesFactory.makeCharacterInfoView(characterModel: character, imageData: imageData)
        let charInfoView = charInfoModule.view
        let charInfoCoordination = charInfoModule.coordination
        
        charInfoCoordination.finish = {
            self.router.popToRoot(charInfoView)
        }
        
        self.router.push(charInfoView, to: navigationController)
    }
}
