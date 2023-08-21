protocol ModulesFactoryProtocol: AnyObject {
    var networkManager: NetworkManagerProtocol { get }
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination)
    //func makeCharacterInfoView() -> (view: Presentable, coordination: CharacterInfoCoordination)
}

final class ModulesFactory: ModulesFactoryProtocol {
    let networkManager: NetworkManagerProtocol = NetworkManager(networkService: DefaultNetworkClient())
    
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination) {
        let listVM = CharactersListViewModel()
        let list = CharactersListViewController(viewModel: listVM)
        return (list, listVM)
    }
}
