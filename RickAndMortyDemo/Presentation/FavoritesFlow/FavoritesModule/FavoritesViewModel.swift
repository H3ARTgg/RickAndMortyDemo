import Foundation

// MARK: - FavoritesCoordination
protocol FavoritesCoordination: AnyObject {
    /// Callback for routing to CharacterInfo Screen
    var headForCharacterInfo: ((CharacterModel, Data) -> Void)? { get set }
}

// MARK: - FavoritesViewModelProtocol
protocol FavoritesViewModelProtocol: AnyObject {
    /// Route to CharacterInfo Screen (triggers headForCharacterInfo)
    func routeToCharacterInfo(with indexPath: IndexPath)
}

// MARK: - FavoritesViewModel
final class FavoritesViewModel: FavoritesViewModelProtocol, FavoritesCoordination {
    // MARK: - Properties
    var headForCharacterInfo: ((CharacterModel, Data) -> Void)?
    
    private let networkManager: NetworkManagerProtocol
    private let realmStorage: StorageProtocol
    private var characterModel: CharacterModel?
    private var imageData: Data?
    
    // MARK: - Init
    init(networkManager: NetworkManagerProtocol, realmStorage: StorageProtocol) {
        self.networkManager = networkManager
        self.realmStorage = realmStorage
    }
    
    /// Route to CharacterInfo Screen (triggers headForCharacterInfo)
    func routeToCharacterInfo(with indexPath: IndexPath) {
        guard let characterModel, let imageData else { return }
        headForCharacterInfo?(characterModel, imageData)
    }
}
