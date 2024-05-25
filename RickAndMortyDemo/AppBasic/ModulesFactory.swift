import Foundation

// MARK: - ModulesFactoryProtocol
protocol ModulesFactoryProtocol: AnyObject {
    var networkManager: NetworkManagerProtocol { get }
    /// Making characters list screen
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination)
    /// Making character info screen
    func makeCharacterInfoView(characterModel: CharacterModel, imageData: Data) -> (view: Presentable, coordination: CharacterInfoCoordination)
}

// MARK: - ModulesFactory
final class ModulesFactory: ModulesFactoryProtocol {
    let networkManager: NetworkManagerProtocol = NetworkManager(networkService: DefaultNetworkClient())
    
    /// Making characters list screen
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination) {
        let listVM = CharactersListViewModel(networkManager: networkManager)
        let list = CharactersListViewController(viewModel: listVM)
        return (list, listVM)
    }
    
    /// Making character info screen
    func makeCharacterInfoView(characterModel: CharacterModel, imageData: Data) -> (view: Presentable, coordination: CharacterInfoCoordination) {
        let charInfoVM = CharacterInfoViewModel(networkManager: networkManager, characterModel: characterModel, imageData: imageData)
        let charInfo = CharacterInfoViewController(viewModel: charInfoVM)
        return (charInfo, charInfoVM)
    }
}
