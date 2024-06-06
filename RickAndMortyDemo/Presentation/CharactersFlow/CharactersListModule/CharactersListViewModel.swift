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
    var errorPublisher: AnyPublisher<NetworkError, Never> { get }
    
    /// Requesting next 10 characters or request already downloaded characters
    func requestCharacters(isNext: Bool)
    /// Get download characters count (Int)
    func getCharactersCount() -> Int
    /// Move to CharacterInfo Screen (triggers headForCharacterInfo)
    func moveToCharacterInfo(with indexPath: IndexPath)
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
    func requestCharacters(isNext: Bool) {
        if !isNext {
            print(charactersCellModels.count)
            print(charactersModels.count)
            charactersSubject.send((charactersCellModels, isNext))
            return
        }
        
        networkManager.getCharactersPublisher(characterIdsRange: calculateRange(&showedIds))
            .flatMap { [unowned self] characters in
                characters.publisher
                    .flatMap { character in
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
                    showedIds = oldShowedIds
                    self.errorSubject.send(error)
                }
            }, receiveValue: { [weak self] results in
                guard let self = self else { return }
                /// adding characters
                self.charactersModels.append(contentsOf: results)
                
                let cellModels = results.map { CharactersListCellModel(name: $0.0.name, imageData: $0.1) }
                self.charactersCellModels.append(contentsOf: cellModels)
                self.charactersSubject.send((cellModels, isNext))
            })
            .store(in: &cancellables)
    }
    
    func moveToCharacterInfo(with indexPath: IndexPath) {
        let characterModel = charactersModels[indexPath.row]
        headForCharacterInfo?(characterModel.model, characterModel.imageData)
    }
    
    func getCharactersCount() -> Int {
        return charactersCellModels.count
    }
    
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
                let cellModels = foundCharacters.map { CharactersListCellModel(name: $0.0.name, imageData: $0.1) }
                self.characterSearchSubject.send(cellModels)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    private func calculateRange(_ showedIds: inout Int) -> Range<Int> {
        let range = Range((showedIds + 1)...(showedIds + 10))
        oldShowedIds = showedIds
        showedIds = oldShowedIds + 10
        print("old", oldShowedIds, "new", showedIds)
        return range
    }
}
