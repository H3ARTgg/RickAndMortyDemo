import Combine
import Foundation

protocol NetworkManagerProtocol: AnyObject {
    func getCharactersPublisher(characterIdsRange: Range<Int>) -> AnyPublisher<[CharacterModel], Never>
    func getImagesPublisher(urls: [String]) -> AnyPublisher<[Data], Never>
    func getImagePublisher(url: String) -> AnyPublisher<Data, Never>
    func getCharacterOriginPublisher(url: String) -> AnyPublisher<CharacterOriginModel, NetworkError>
    func getEpisodesPublisher(urls: [String]) -> AnyPublisher<[EpisodeModel], NetworkError>
    func getEpisodePublisher(url: String) -> AnyPublisher<EpisodeModel, NetworkError>
}

final class NetworkManager: NetworkManagerProtocol {
    private let networkService: NetworkClient
    
    init(networkService: NetworkClient) {
        self.networkService = networkService
    }
    
    func getCharactersPublisher(characterIdsRange: Range<Int>) -> AnyPublisher<[CharacterModel], Never> {
        let request = CharactersRequest(characterIdsRange)
        return networkService.networkPublisher(request: request, type: [CharacterModel].self)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getImagePublisher(url: String) -> AnyPublisher<Data, Never> {
        let request = ImageRequest(url: url)
        return networkService.networkPublisher(request: request)
            .replaceError(with: Data())
            .eraseToAnyPublisher()
    }
    
    func getImagesPublisher(urls: [String]) -> AnyPublisher<[Data], Never> {
        return urls.publisher
            .flatMap(getImagePublisher)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getCharacterOriginPublisher(url: String) -> AnyPublisher<CharacterOriginModel, NetworkError> {
        let request = CharacterOriginRequest(url: url)
        return networkService.networkPublisher(request: request, type: CharacterOriginModel.self)
            .eraseToAnyPublisher()
    }
    
    func getEpisodesPublisher(urls: [String]) -> AnyPublisher<[EpisodeModel], NetworkError> {
        let request = EpisodesRequest(episodes: urls)
        return networkService.networkPublisher(request: request, type: [EpisodeModel].self)
            .eraseToAnyPublisher()
    }
    
    func getEpisodePublisher(url: String) -> AnyPublisher<EpisodeModel, NetworkError> {
        let request = EpisodesRequest(episodes: [url])
        return networkService.networkPublisher(request: request, type: EpisodeModel.self)
            .eraseToAnyPublisher()
    }
}
