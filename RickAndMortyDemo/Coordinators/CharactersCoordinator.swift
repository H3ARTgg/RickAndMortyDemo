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
        perfomFlow()
    }
}

// MARK: - CharactersCoordinator Extension
private extension CharactersCoordinator {
    func perfomFlow() {
        let charListModule = modulesFactory.makeCharactersListView()
        let charListView = charListModule.view
        var charListCoordination = charListModule.coordination
        
        charListCoordination.headForCharacterInfo = { [weak self] (characterModel, imageData) in
            guard let self else { return }
            let charInfoModule = self.modulesFactory.makeCharacterInfoView(characterModel: characterModel, imageData: imageData)
            let charInfoView = charInfoModule.view
            var charInfoCoordination = charInfoModule.coordination
            
            charInfoCoordination.finish = {
                self.router.popToRoot(charInfoView)
            }
            
            self.router.push(charInfoView, to: navController)
        }
        
        router.push(charListView, to: navController)
    }
}
