import UIKit
import Combine

protocol CharactersListCoordination {
    var finish: (() -> Void)? { get set }
    var headForCharacterInfo: (() -> Void)? { get set }
}

protocol CharactersListViewModelProtocol: AnyObject {
    var charactersPublisher: AnyPublisher<[CharacterModel], NetworkError> { get }
    var getCharacters: PassthroughSubject<Void, NetworkError> { get }
    var imagesPublisher: AnyPublisher<[Data], NetworkError> { get }
    var getImages: PassthroughSubject<[String], NetworkError> { get }
    var showLoading: AnyPublisher<Bool, Never> { get }
    func recieveCellModels() -> [CharactersListCellModel]
    func requestCharacters()
    func getCharactersCount() -> Int
}

final class CharactersListViewModel: CharactersListViewModelProtocol & CharactersListCoordination {
    var finish: (() -> Void)?
    var headForCharacterInfo: (() -> Void)?
    private(set) var charactersPublisher: AnyPublisher<[CharacterModel], NetworkError>
    private(set) var imagesPublisher: AnyPublisher<[Data], NetworkError>
    private(set) var getImages = PassthroughSubject<[String], NetworkError>()
    private(set) var getCharacters = PassthroughSubject<Void, NetworkError>()
    var showLoading: AnyPublisher<Bool, Never> {
        showLoadingSubject.eraseToAnyPublisher()
    }
    private var showedIds: Int = 0
    private let imagesSubject = CurrentValueSubject<[Data], Never>([])
    private let charactersSubject = CurrentValueSubject<[CharacterModel], NetworkError>([])
    private let showLoadingSubject = PassthroughSubject<Bool, Never>()
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        self.imagesPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
        self.charactersPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
        
        charactersPublisher = getCharacters.flatMap({ [unowned self] _ in
            showLoadingSubject.send(true)
            return self.networkManager.getCharactersPublisher(characterIdsRange: calculateRange(&self.showedIds))
                .receive(on: DispatchQueue.main)
                .removeDuplicates()
                .handleEvents(receiveOutput: { [weak self] characters in
                    self?.charactersSubject.value.append(contentsOf: characters)
                    self?.getImages.send(characters.map(\.image))
                })
                .handleEvents(receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        // calls alert
                    }
                })
        })
        .eraseToAnyPublisher()
        
        imagesPublisher = getImages.flatMap({ [unowned self] urls in
            return networkManager.getImagesPublisher(urls: urls)
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { [weak self] images in
                    self?.imagesSubject.value.append(contentsOf: images)
                    self?.showLoadingSubject.send(false)
                })
        }).eraseToAnyPublisher()
    }
    
    func requestCharacters() {
        getCharacters.send()
    }
    
    func recieveCellModels() -> [CharactersListCellModel] {
        var cellModels: [CharactersListCellModel] = []
        let characters = charactersSubject.value
        let images = imagesSubject.value
        for indx in characters.startIndex..<characters.endIndex {
            let cellModel = CharactersListCellModel(id: UUID(), name: characters[indx].name, imageData: images[indx], rowNumber: 0)
            cellModels.append(cellModel)
        }
        return cellModels
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
