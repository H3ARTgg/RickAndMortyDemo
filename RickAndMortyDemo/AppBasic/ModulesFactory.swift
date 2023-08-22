import Foundation

protocol ModulesFactoryProtocol: AnyObject {
    var networkManager: NetworkManagerProtocol { get }
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination)
    func makeCharacterInfoView(characterModel: CharacterModel, imageData: Data) -> (view: Presentable, coordination: CharacterInfoCoordination)
}

final class ModulesFactory: ModulesFactoryProtocol {
    let networkManager: NetworkManagerProtocol = NetworkManager(networkService: DefaultNetworkClient())
    
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination) {
        let listVM = CharactersListViewModel(networkManager: networkManager)
        let list = CharactersListViewController(viewModel: listVM)
        return (list, listVM)
    }
    
    func makeCharacterInfoView(characterModel: CharacterModel, imageData: Data) -> (view: Presentable, coordination: CharacterInfoCoordination) {
        let charInfoVM = CharacterInfoViewModel(networkManager: networkManager, characterModel: characterModel, imageData: imageData)
        let charInfo = CharacterInfoViewController(viewModel: charInfoVM)
        return (charInfo, charInfoVM)
    }
}
