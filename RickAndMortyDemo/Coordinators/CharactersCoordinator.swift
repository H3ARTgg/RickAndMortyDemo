import Foundation

// MARK: - CharactersCoordinator
final class CharactersCoordinator: BaseCoordinator, Coordinatable {
    var finishFlow: (() -> Void)?
    private let modulesFactory: ModulesFactoryProtocol
    private let router: Routable
    private let navController: CharactersListNavCon
    
    // MARK: - Init
    init(modulesFactory: ModulesFactoryProtocol, router: Routable, navCon: CharactersListNavCon) {
        self.modulesFactory = modulesFactory
        self.router = router
        self.navController = navCon
    }
    
    func startFlow() {
        routeToCharacterList()
    }
}

// MARK: - CharactersCoordinator Extension
private extension CharactersCoordinator {
    func routeToCharacterList() {
        let charListModule = modulesFactory.makeCharactersListView()
        let charListView = charListModule.view
        let charListCoordination = charListModule.coordination
        
        charListCoordination.headForCharacterInfo = { [weak self] (characterModel, imageData) in
            guard let self else { return }
            // routing to CharacterInfo
            routeToCharacrerInfo(character: characterModel, imageData: imageData)
        }
        
        router.push(charListView, to: navController)
    }
    
    func routeToCharacrerInfo(character: CharacterModel, imageData: Data) {
        let charInfoModule = self.modulesFactory.makeCharacterInfoView(characterModel: character, imageData: imageData)
        let charInfoView = charInfoModule.view
        let charInfoCoordination = charInfoModule.coordination
        
        charInfoCoordination.finish = {
            self.router.popToRoot(charInfoView)
        }
        
        self.router.push(charInfoView, to: navController)
    }
}
