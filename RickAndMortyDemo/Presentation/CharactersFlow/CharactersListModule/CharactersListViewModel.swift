import UIKit
import Combine

protocol CharactersListCoordination {
    // Callback for routing to CharacterInfo Screen
    var headForCharacterInfo: ((CharacterModel, _ imageData: Data) -> Void)? { get set }
}

protocol CharactersListViewModelProtocol: AnyObject {
    // Publishes CharactersListModel array (10 models) or NetworkError
    var charactersPublisher: AnyPublisher<[CharactersListCellModel], NetworkError> { get }
    var getCharacters: PassthroughSubject<Void, NetworkError> { get }
    var errorPublisher: AnyPublisher<NetworkError, Never> { get }
    var showLoading: AnyPublisher<Bool, Never> { get }
    func requestCharacters()
    func getCharactersCount() -> Int
    func moveToCharacterInfo(with indexPath: IndexPath)
}

final class CharactersListViewModel: CharactersListViewModelProtocol & CharactersListCoordination {
    var headForCharacterInfo: ((CharacterModel, _ imageData: Data) -> Void)?
    var errorPublisher: AnyPublisher<NetworkError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    private(set) var charactersPublisher: AnyPublisher<[CharactersListCellModel], NetworkError>
    private(set) var getCharacters = PassthroughSubject<Void, NetworkError>()
    var showLoading: AnyPublisher<Bool, Never> {
        showLoadingSubject.eraseToAnyPublisher()
    }
    private let errorSubject = PassthroughSubject<NetworkError, Never>()
    private let charactersSubject = PassthroughSubject<[CharactersListCellModel], Never>()
    private let showLoadingSubject = PassthroughSubject<Bool, Never>()
    private let networkManager: NetworkManagerProtocol
    
    private var charactersModels: [(model: CharacterModel, imageData: Data)] = []
    private var showedIds: Int = 0
    var cellModels: [CharactersListCellModel] = []
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        self.charactersPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
        
        charactersPublisher = getCharacters.flatMap({ [unowned self] _ in
            showLoadingSubject.send(true)
            return self.networkManager.getCharactersPublisher(characterIdsRange: calculateRange(&self.showedIds))
                .flatMap { responces in
                    responces.publisher.setFailureType(to: NetworkError.self)
                }
                .flatMap { responce in
                return self.networkManager.getImagePublisher(url: responce.image)
                    .compactMap { image in
                        self.charactersModels.append((responce, image))
                        return CharactersListCellModel(id: UUID(), name: responce.name, imageData: image)
                    }
            }
                .collect()
                .receive(on: DispatchQueue.main)
        })
        .handleEvents(receiveCompletion: { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                return
            case .failure(let error):
                self.errorSubject.send(error)
            }
        })
        .handleEvents(receiveOutput: { [weak self] characterModel in
            guard let self else { return }
            self.showLoadingSubject.send(false)
            self.charactersSubject.send(characterModel)
        })
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    func moveToCharacterInfo(with indexPath: IndexPath) {
        headForCharacterInfo?(charactersModels[indexPath.row].model, charactersModels[indexPath.row].imageData)
    }
    
    func requestCharacters() {
        getCharacters.send()
    }
    
    func getCharactersCount() -> Int {
        self.charactersModels.count
    }
    
    private func calculateRange(_ showedIds: inout Int) -> Range<Int> {
        var range: Range<Int>
        if showedIds == 0 {
            range = Range((showedIds + 1)...(showedIds + 10))
            showedIds += 10
        } else {
            range = Range(showedIds + 1...(showedIds + 10))
            showedIds += 10
        }
        return range
    }
}
