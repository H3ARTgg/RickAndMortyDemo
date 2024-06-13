import Foundation
import Combine

// MARK: - FavoritesCoordination
protocol FavoritesCoordination: AnyObject {
    /// Callback for routing to CharacterInfo Screen
    var headForCharacterInfo: ((CharacterModel, Data) -> Void)? { get set }
}

// MARK: - FavoritesViewModelProtocol
protocol FavoritesViewModelProtocol: AnyObject {
    /// Publishes error
    var errorPublisher: AnyPublisher<NetworkError, Never> { get }
    /// Publishes CharactersListModel array (10 models)
    var charactersPublisher: AnyPublisher<[CharactersListCellModel], Never> { get }
    
    /// Route to CharacterInfo Screen (triggers headForCharacterInfo)
    func routeToCharacterInfo(with indexPath: IndexPath)
    /// Request favorite characters
    func requestFavoriteCharacters()
}

// MARK: - FavoritesViewModel
final class FavoritesViewModel: FavoritesViewModelProtocol, FavoritesCoordination {
    // MARK: - Properties
    /// Callback for routing to CharacterInfo Screen
    var headForCharacterInfo: ((CharacterModel, Data) -> Void)?
    
    /// Publishes CharactersListModel array (10 models)
    private let charactersSubject = CurrentValueSubject<[CharactersListCellModel], Never>([])
    var charactersPublisher: AnyPublisher<[CharactersListCellModel], Never> {
        charactersSubject.eraseToAnyPublisher()
    }
    
    /// Publishes error
    private let errorSubject = PassthroughSubject<NetworkError, Never>()
    var errorPublisher: AnyPublisher<NetworkError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    private let networkManager: NetworkManagerProtocol
    private let realmStorage: StorageProtocol
    private var charactersModels: [(model: CharacterModel, imageData: Data)] = []
    private var currentFavoritesCount: Int = 0
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Init
    init(networkManager: NetworkManagerProtocol, realmStorage: StorageProtocol) {
        self.networkManager = networkManager
        self.realmStorage = realmStorage
        self.realmStorage.delegate = self
    }
    
    /// Request favorite characters
    func requestFavoriteCharacters() {
        let oldCount = currentFavoritesCount
        let favoritesIdsArray = realmStorage.getFavorites().sorted()
        currentFavoritesCount = favoritesIdsArray.count
        /// if favorites count doesn't changed, then return
        guard oldCount != currentFavoritesCount else { return }
        /// if is favorites empty, then send empty array
        guard currentFavoritesCount != 0 else { charactersSubject.send([]); return }
        
        networkManager.getCharactersPublisher(characterIds: favoritesIdsArray)
            .flatMap { [unowned self] characters in
                characters.publisher
                    .flatMap { character in
                        /// downloading image for character
                        self.networkManager.getImagePublisher(url: character.image)
                            .map { imageData in
                                (character, imageData)
                            }
                    }
                    .collect()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.errorSubject.send(error)
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                charactersModels = results.map({ ($0.0, $0.1) })
                
                /// making models for cells
                let cellModels = results.map { CharactersListCellModel(characterId: $0.0.id, name: $0.0.name, imageData: $0.1, storage: self.realmStorage) }
                self.charactersSubject.send((cellModels))
            })
            .store(in: &cancellables)
    }
    
    /// Route to CharacterInfo Screen (triggers headForCharacterInfo)
    func routeToCharacterInfo(with indexPath: IndexPath) {
        guard charactersModels.indices.contains(indexPath.row) else { return }
        let characterModel = charactersModels[indexPath.row]
        headForCharacterInfo?(characterModel.model, characterModel.imageData)
    }
}

// MARK: - RealmStorageDelegate
extension FavoritesViewModel: RealmStorageDelegate {
    func favoritesChanged() {
        requestFavoriteCharacters()
    }
}
