import UIKit
import Combine

protocol CharactersListCoordination {
    /// Callback for routing to CharacterInfo Screen
    var headForCharacterInfo: ((CharacterModel, _ imageData: Data) -> Void)? { get set }
}

protocol CharactersListViewModelProtocol: AnyObject {
    /// Publishes CharactersListModel array (10 models) or empty array (if its error)
    var charactersPublisher: AnyPublisher<[CharactersListCellModel], Never> { get }
    /// Publishes Bool value. Is downloading in progress
    var showLoading: AnyPublisher<Bool, Never> { get }
    /// Requesting 10 next characters
    func requestCharacters()
    /// Get download characters count (Int)
    func getCharactersCount() -> Int
    /// Move to CharacterInfo Screen (triggers headForCharacterInfo)
    func moveToCharacterInfo(with indexPath: IndexPath)
}

final class CharactersListViewModel: CharactersListViewModelProtocol & CharactersListCoordination {
    var headForCharacterInfo: ((CharacterModel, _ imageData: Data) -> Void)?
    var charactersPublisher: AnyPublisher<[CharactersListCellModel], Never>
    var showLoading: AnyPublisher<Bool, Never> {
        showLoadingSubject.eraseToAnyPublisher()
    }
    private let getCharacters = PassthroughSubject<Void, Never>()
    private let showLoadingSubject = PassthroughSubject<Bool, Never>()
    private let networkManager: NetworkManagerProtocol
    
    private var charactersModels: [(model: CharacterModel, imageData: Data)] = []
    private var showedIds: Int = 0
    private var isShowedIdsJustIncreased: Bool = false
    var cellModels: [CharactersListCellModel] = []
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        self.charactersPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
        
        charactersPublisher = getCharacters.flatMap({ [unowned self] _ in
            showLoadingSubject.send(true)
            return self.networkManager.getCharactersPublisher(characterIdsRange: calculateRange(&self.showedIds))
                .flatMap { responces in
                    return responces.publisher
                        .replaceError(with: .init(id: -1, name: "Error", status: "", species: "", type: "", gender: "", origin: .init(name: "", url: ""), image: "", episode: [""]))
                }
                .flatMap { responce in
                return self.networkManager.getImagePublisher(url: responce.image)
                        .replaceError(with: Data())
                    .compactMap { image in
                        self.charactersModels.append((responce, image))
                        return CharactersListCellModel(id: UUID(), name: responce.name, imageData: image)
                    }
            }
                .collect()
                .receive(on: DispatchQueue.main)
        })
        .handleEvents(receiveOutput: { [weak self] characterModel in
            guard let self else { return }
            if characterModel.isEmpty && isShowedIdsJustIncreased {
                showedIds -= 10
            }
            isShowedIdsJustIncreased = false
            self.showLoadingSubject.send(false)
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
            isShowedIdsJustIncreased = true
        } else {
            range = Range(showedIds + 1...(showedIds + 10))
            showedIds += 10
            isShowedIdsJustIncreased = true
        }
        return range
    }
}
