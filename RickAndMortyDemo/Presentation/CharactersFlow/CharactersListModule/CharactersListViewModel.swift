import UIKit
import Combine

protocol CharactersListCoordination {
    var finish: (() -> Void)? { get set }
    var headForCharacterInfo: ((CharacterModel, _ imageData: Data) -> Void)? { get set }
}

protocol CharactersListViewModelProtocol: AnyObject {
    var charactersPublisher: AnyPublisher<[CharactersListCellModel], NetworkError> { get }
    var getCharacters: PassthroughSubject<Void, NetworkError> { get }
    var showLoading: AnyPublisher<Bool, Never> { get }
    func requestCharacters()
    func getCharactersCount() -> Int
    func getCharactersArray() -> [CharactersListCellModel]
    func moveToCharacterInfo(with indexPath: IndexPath)
}

final class CharactersListViewModel: CharactersListViewModelProtocol & CharactersListCoordination {
    var finish: (() -> Void)?
    var headForCharacterInfo: ((CharacterModel, _ imageData: Data) -> Void)?
    private(set) var charactersPublisher: AnyPublisher<[CharactersListCellModel], NetworkError>
    private(set) var getCharacters = PassthroughSubject<Void, NetworkError>()
    var showLoading: AnyPublisher<Bool, Never> {
        showLoadingSubject.eraseToAnyPublisher()
    }
    private var showedIds: Int = 0
    private let charactersSubject = CurrentValueSubject<[CharactersListCellModel], NetworkError>([])
    private var charactersModels: [CharacterModel] = []
    private let showLoadingSubject = PassthroughSubject<Bool, Never>()
    private let networkManager: NetworkManagerProtocol
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
                    self.charactersModels.append(responce)
                return self.networkManager.getImagePublisher(url: responce.image)
                    .compactMap { image in
                        CharactersListCellModel(id: UUID(), name: responce.name, imageData: image)
                    }
            }
                .collect()
                .receive(on: DispatchQueue.main)
        })
        .handleEvents(receiveOutput: { [weak self] characterModel in
            guard let self else { return }
            self.showLoadingSubject.send(false)
            self.charactersSubject.value.append(contentsOf: characterModel)
        })
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    func moveToCharacterInfo(with indexPath: IndexPath) {
        headForCharacterInfo?(charactersModels[indexPath.row], charactersSubject.value[indexPath.row].imageData)
    }
    
    func requestCharacters() {
        getCharacters.send()
    }
    
    func getCharactersArray() -> [CharactersListCellModel] {
        self.charactersSubject.value
    }
    
    func getCharactersCount() -> Int {
        self.charactersSubject.value.count
    }
    
    private func calculateRange(_ showedIds: inout Int) -> Range<Int> {
        var range = Range(1...2)
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
