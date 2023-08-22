import Foundation
import Combine

protocol CharacterInfoCoordination {
    var finish: (() -> Void)? { get set }
}

protocol CharacterInfoViewModelProtocol: AnyObject {
    var characterInfoPublisher: AnyPublisher<CharacterModel, Never> { get }
    var characterOriginPublisher: AnyPublisher<CharacterOriginModel, NetworkError> { get }
    var episodesPublisher: AnyPublisher<[EpisodeModel], NetworkError> { get }
    
    var getOrigin: PassthroughSubject<Void, NetworkError> { get }
    var getEpidodes: PassthroughSubject<Void, NetworkError> { get }
    
    func moveBackToRootViewController()
}

final class CharacterInfoViewModel: CharacterInfoViewModelProtocol, CharacterInfoCoordination {
    var characterInfoPublisher: AnyPublisher<CharacterModel, Never>
    var characterOriginPublisher: AnyPublisher<CharacterOriginModel, NetworkError>
    var episodesPublisher: AnyPublisher<[EpisodeModel], NetworkError>
    
    var getOrigin = PassthroughSubject<Void, NetworkError>()
    var getEpidodes = PassthroughSubject<Void, NetworkError>()
    
    var finish: (() -> Void)?
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol, characterModel: CharacterModel, imageData: Data) {
        self.networkManager = networkManager
        self.characterInfoPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
        self.characterOriginPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
        self.episodesPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
        
    }
    
    func moveBackToRootViewController() {
        finish?()
    }
}
