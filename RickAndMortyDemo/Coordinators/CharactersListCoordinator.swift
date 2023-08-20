import Foundation

final class CharactersListCoordinator: BaseCoordinator, Coordinatable {
    var finishFlow: (() -> Void)?
    private var modulesFactory: ModulesFactoryProtocol
    private var router: Routable
    private let navController: CharactersListNavCon
    
    init(modulesFactory: ModulesFactoryProtocol, router: Routable, navCon: CharactersListNavCon) {
        self.modulesFactory = modulesFactory
        self.router = router
        self.navController = navCon
    }
    
    func startFlow() {
        perfomFlow()
    }
}

private extension CharactersListCoordinator {
    func perfomFlow() {
        let charListModule = modulesFactory.makeCharactersListView()
        let charListView = charListModule.view
        let charListCoordination = charListModule.coordination
        
        router.push(charListView, to: navController)
    }
}
