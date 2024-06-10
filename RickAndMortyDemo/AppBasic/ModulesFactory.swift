import Foundation

// MARK: - ModulesFactoryProtocol
protocol ModulesFactoryProtocol: AnyObject {
    /// Making characters list screen
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination)
    /// Making character info screen
    func makeCharacterInfoView(characterModel: CharacterModel, imageData: Data) -> (view: Presentable, coordination: CharacterInfoCoordination)
    /// Making favorites screen
    func makeFavoritesView() -> (view: Presentable, coordination: FavoritesCoordination)
}

// MARK: - ModulesFactory
final class ModulesFactory: ModulesFactoryProtocol {
    private let networkManager: NetworkManagerProtocol
    private let storage: StorageProtocol
    
    init(networkManager: NetworkManagerProtocol, storage: StorageProtocol) {
        self.networkManager = networkManager
        self.storage = storage
    }
    /// Making characters list screen
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination) {
        let listVM = CharactersListViewModel(networkManager: networkManager, storage: storage)
        let list = CharactersListViewController(viewModel: listVM)
        return (list, listVM)
    }
    
    /// Making character info screen
    func makeCharacterInfoView(characterModel: CharacterModel, imageData: Data) -> (view: Presentable, coordination: CharacterInfoCoordination) {
        let charInfoVM = CharacterInfoViewModel(networkManager: networkManager, characterModel: characterModel, imageData: imageData)
        let charInfo = CharacterInfoViewController(viewModel: charInfoVM)
        return (charInfo, charInfoVM)
    }
    
    /// Making favorites screen
    func makeFavoritesView() -> (view: Presentable, coordination: FavoritesCoordination) {
        let favoritesVM = FavoritesViewModel(networkManager: networkManager, realmStorage: storage)
        let favorites = FavoritesViewController(viewModel: favoritesVM)
        return (favorites, favoritesVM)
    }
}
