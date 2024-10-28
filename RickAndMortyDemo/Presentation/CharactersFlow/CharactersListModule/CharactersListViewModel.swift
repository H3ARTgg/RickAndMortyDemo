import UIKit
import Combine
import Moya

// MARK: - CharactersListCoordination Protocol
protocol CharactersListCoordination: AnyObject {
    /// Callback for routing to CharacterInfo Screen
    var headForCharacterInfo: ((CharacterModel, Data) -> Void)? { get set }
}

// MARK: - CharactersListViewModelProtocol
protocol CharactersListViewModelProtocol: AnyObject {
    /// Publishes CharactersListModel array (10 models)
    var charactersPublisher: AnyPublisher<(cellModels: [CharactersListCellModel], isNext: Bool), Never> { get }
    /// Publishes search results
    var characterSearchPublisher: AnyPublisher<(cellModels: [CharactersListCellModel], isNext: Bool), Never> { get }
    /// Publishes error
    var errorPublisher: AnyPublisher<MoyaError, Never> { get }
    
    /// Requesting next 10 characters or request already downloaded characters
    func requestCharacters(isNext: Bool)
    /// Get download characters count (Int)
    func getCharactersCount() -> Int
    /// Route to CharacterInfo Screen (triggers headForCharacterInfo)
    func routeToCharacterInfo(with indexPath: IndexPath)
    /// Search characters by filter
    func search(_ text: String?, isNext: Bool)
    /// Set search types (filters)
    func setFilters(_ types: [CharacterSearchType])
}

// MARK: - CharactersListViewModel
final class CharactersListViewModel: CharactersListViewModelProtocol, CharactersListCoordination {
    // MARK: - Properties
    /// Callback for routing to CharacterInfo Screen
    var headForCharacterInfo: ((CharacterModel, Data) -> Void)?
    
    /// Publishes CharactersListModel array (10 models)
    private let charactersSubject = PassthroughSubject<(cellModels: [CharactersListCellModel], isNext: Bool), Never>()
    var charactersPublisher: AnyPublisher<(cellModels: [CharactersListCellModel], isNext: Bool), Never> {
        charactersSubject.eraseToAnyPublisher()
    }
    
    /// Publishes search results
    private let characterSearchSubject = PassthroughSubject<(cellModels: [CharactersListCellModel], isNext: Bool), Never>()
    var characterSearchPublisher: AnyPublisher<(cellModels: [CharactersListCellModel], isNext: Bool), Never> {
        characterSearchSubject.eraseToAnyPublisher()
    }
    
    /// Publishes error
    private let errorSubject = PassthroughSubject<MoyaError, Never>()
    var errorPublisher: AnyPublisher<MoyaError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    private let networkManager: NetworkManagerProtocol
    private let realmStorage: StorageProtocol
    
    private var charactersModels: [(model: CharacterModel, imageData: Data)] = []
    private var charactersCellModels: [CharactersListCellModel] = []
    private var oldShowedIds: Int = 0
    private var showedIds: Int = 0
    private var cancellables = Set<AnyCancellable>()
    
    // Searching
    private var currentFilters: [CharacterSearchType] = []
    private var isSearching: Bool = false
    private var searchedModels: [(model: CharacterModel, imageData: Data)] = []
    private var nextPage: String?
    
    // MARK: - Init
    init(networkManager: NetworkManagerProtocol, storage: StorageProtocol) {
        self.networkManager = networkManager
        self.realmStorage = storage
    }
    
    // MARK: - CharactersListViewModelProtocol
    /// Requesting next 10 characters or request already downloaded characters
    func requestCharacters(isNext: Bool) {
        /// showing already downloaded characters
        if !isNext {
            isSearching = false
            nextPage = nil
            searchedModels = []
            
            charactersSubject.send((charactersCellModels, isNext))
            return
        }
        
        if isSearching {
            search("", isNext: isNext)
            return
        }
        
        /// requesting new 10 characters
        networkManager.characters(ids: calculateRange(&showedIds))
            .flatMap { [unowned self] characters in
                characters.publisher
                    .flatMap { character in
                        /// downloading image for character
                        self.networkManager.image(url: character.image)
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
                let cellModels = results.map { CharactersListCellModel(characterId: $0.0.id, name: $0.0.name, imageData: $0.1, storage: self.realmStorage) }
                self.charactersCellModels.append(contentsOf: cellModels)
                self.charactersSubject.send((cellModels, isNext))
            })
            .store(in: &cancellables)
    }
    
    /// Route to CharacterInfo Screen (triggers headForCharacterInfo)
    func routeToCharacterInfo(with indexPath: IndexPath) {
        let model: (model: CharacterModel, imageData: Data)
        
        if isSearching {
            guard searchedModels.indices.contains(indexPath.row) else { return }
            model = searchedModels[indexPath.row]
        } else {
            guard charactersModels.indices.contains(indexPath.row) else { return }
            model = charactersModels[indexPath.row]
        }
        
        headForCharacterInfo?(model.model, model.imageData)
    }
    
    /// Get download characters count (Int)
    func getCharactersCount() -> Int {
        if isSearching {
            return searchedModels.count
        } else {
            return charactersCellModels.count
        }
    }
    
    /// Search characters by filter
    func search(_ text: String?, isNext: Bool = false) {
        isSearching = true
        var newFilters = currentFilters
        
        if let text, !text.isEmpty {
            let nameType = CharacterSearchType.name(name: text)
            newFilters.append(nameType)
        }
        let publisher: AnyPublisher<CharacterSearch, MoyaError>
        
        if isNext {
            if let nextPage {
                publisher = networkManager.search(filters: newFilters, nextPage: nextPage)
            } else {
                self.characterSearchSubject.send(([], isNext: isNext))
                return
            }
        } else {
            nextPage = nil
            searchedModels = []
            
            publisher = networkManager.search(filters: newFilters, nextPage: nil)
        }
        
        publisher
            .flatMap({ [unowned self] characterNameModel in
                self.nextPage = characterNameModel.info.next
                return characterNameModel.results.publisher
                    .flatMap { characterModel in
                        self.networkManager.image(url: characterModel.image)
                            .map { imageData in
                                (characterModel, imageData)
                            }
                    }
                    .collect()
            })
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(_) = completion {
                    self.characterSearchSubject.send(([], isNext: isNext))
                }
            }, receiveValue: { [weak self] foundCharacters in
                guard let self else { return }
                /// making models for cells
                searchedModels.append(contentsOf: foundCharacters)
                
                let cellModels = foundCharacters.map { CharactersListCellModel(characterId: $0.0.id, name: $0.0.name, imageData: $0.1, storage: self.realmStorage) }
                self.characterSearchSubject.send((cellModels, isNext))
            })
            .store(in: &cancellables)
    }
    
    func setFilters(_ types: [CharacterSearchType]) {
        currentFilters = types
    }
    
    // MARK: - Private Methods
    /// Calculating range for next character ids
    private func calculateRange(_ showedIds: inout Int) -> [Int] {
        let array = Array((showedIds + 1)...(showedIds + 10))
        oldShowedIds = showedIds
        showedIds = oldShowedIds + 10
        return array
    }
}
