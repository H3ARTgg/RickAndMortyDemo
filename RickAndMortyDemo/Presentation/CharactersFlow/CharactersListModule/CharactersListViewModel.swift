import UIKit
import Combine

// MARK: - CharactersListCoordination Protocol
protocol CharactersListCoordination: AnyObject {
    /// Callback for routing to CharacterInfo Screen
    var headForCharacterInfo: ((CharacterModel, Data) -> Void)? { get set }
}

// MARK: - CharactersListViewModelProtocol
protocol CharactersListViewModelProtocol: AnyObject {
    /// Publishes CharactersListModel array (10 models) or empty array (if it's an error)
    var charactersPublisher: AnyPublisher<(cellModels: [CharactersListCellModel], isNext: Bool), Never> { get }
    /// Publishes search results
    var characterSearchPublisher: AnyPublisher<[CharactersListCellModel], Never> { get }
    /// Publishes error
    var errorPublisher: AnyPublisher<NetworkError, Never> { get }
    
    /// Requesting next 10 characters or request already downloaded characters
    func requestCharacters(isNext: Bool)
    /// Get download characters count (Int)
    func getCharactersCount() -> Int
    /// Route to CharacterInfo Screen (triggers headForCharacterInfo)
    func routeToCharacterInfo(with indexPath: IndexPath)
    /// Search characters by name
    func search(_ name: String?)
}

// MARK: - CharactersListViewModel
final class CharactersListViewModel: CharactersListViewModelProtocol, CharactersListCoordination {
    /// Callback for routing to CharacterInfo Screen
    var headForCharacterInfo: ((CharacterModel, Data) -> Void)?
    
    /// Publishes CharactersListModel array (10 models) or empty array (if it's an error)
    private let charactersSubject = PassthroughSubject<(cellModels: [CharactersListCellModel], isNext: Bool), Never>()
    var charactersPublisher: AnyPublisher<(cellModels: [CharactersListCellModel], isNext: Bool), Never> {
        charactersSubject.eraseToAnyPublisher()
    }
    
    /// Publishes search results
    private let characterSearchSubject = PassthroughSubject<[CharactersListCellModel], Never>()
    var characterSearchPublisher: AnyPublisher<[CharactersListCellModel], Never> {
        characterSearchSubject.eraseToAnyPublisher()
    }
    
    /// Publishes error
    private let errorSubject = PassthroughSubject<NetworkError, Never>()
    var errorPublisher: AnyPublisher<NetworkError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    private let networkManager: NetworkManagerProtocol
    private var charactersModels: [(model: CharacterModel, imageData: Data)] = []
    private var charactersCellModels: [CharactersListCellModel] = []
    private var oldShowedIds: Int = 0
    private var showedIds: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    // MARK: - CharactersListViewModelProtocol
    /// Requesting next 10 characters or request already downloaded characters
    func requestCharacters(isNext: Bool) {
        /// showing already downloaded characters
        if !isNext {
            charactersSubject.send((charactersCellModels, isNext))
            return
        }
        
        /// requesting new 10 characters
        networkManager.getCharactersPublisher(characterIdsRange: calculateRange(&showedIds))
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
                    /// if fails, then return showedIds value to old value (oldShowedIds)
                    showedIds = oldShowedIds
                    self.errorSubject.send(error)
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                /// adding characters
                self.charactersModels.append(contentsOf: results)
                
                /// making models for cells
                let cellModels = results.map { CharactersListCellModel(name: $0.0.name, imageData: $0.1) }
                self.charactersCellModels.append(contentsOf: cellModels)
                self.charactersSubject.send((cellModels, isNext))
            })
            .store(in: &cancellables)
    }
    
    /// Route to CharacterInfo Screen (triggers headForCharacterInfo)
    func routeToCharacterInfo(with indexPath: IndexPath) {
        let characterModel = charactersModels[indexPath.row]
        headForCharacterInfo?(characterModel.model, characterModel.imageData)
    }
    
    /// Get download characters count (Int)
    func getCharactersCount() -> Int {
        return charactersCellModels.count
    }
    
    /// Search characters by name
    func search(_ name: String?) {
        networkManager.getCharactersByName(name: name ?? "")
            .flatMap({ [unowned self] characterNameModel in
                characterNameModel.results.publisher
                    .flatMap { characterModel in
                        self.networkManager.getImagePublisher(url: characterModel.image)
                            .map { imageData in
                                (characterModel, imageData)
                            }
                    }
                    .collect()
            })
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(_) = completion {
                    self.characterSearchSubject.send([])
                }
            }, receiveValue: { [weak self] foundCharacters in
                guard let self else { return }
                /// making models for cells
                let cellModels = foundCharacters.map { CharactersListCellModel(name: $0.0.name, imageData: $0.1) }
                self.characterSearchSubject.send(cellModels)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    /// Calculating range for next character ids
    private func calculateRange(_ showedIds: inout Int) -> Range<Int> {
        let range = Range((showedIds + 1)...(showedIds + 10))
        oldShowedIds = showedIds
        showedIds = oldShowedIds + 10
        return range
    }
}
