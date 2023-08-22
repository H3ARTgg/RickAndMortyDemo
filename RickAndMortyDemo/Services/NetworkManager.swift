import Combine
import Foundation

protocol NetworkManagerProtocol: AnyObject {
    func getCharactersPublisher(characterIdsRange: Range<Int>) -> AnyPublisher<[CharacterModel], NetworkError>
    func getImagesPublisher(urls: [String]) -> AnyPublisher<[Data], NetworkError>
    func getImagePublisher(url: String) -> AnyPublisher<Data, NetworkError>
    func getCharacterOriginPublisher(url: String) -> AnyPublisher<CharacterOriginModel, NetworkError>
    func getEpisodesPublisher(urls: [String]) -> AnyPublisher<[EpisodeModel], NetworkError>
    func getEpisodePublisher(url: String) -> AnyPublisher<EpisodeModel, NetworkError>
}

final class NetworkManager: NetworkManagerProtocol {
    private let networkService: NetworkClient
    
    init(networkService: NetworkClient) {
        self.networkService = networkService
    }
    
    func getCharactersPublisher(characterIdsRange: Range<Int>) -> AnyPublisher<[CharacterModel], NetworkError> {
        let request = CharactersRequest(characterIdsRange)
        return networkService.networkPublisher(request: request, type: [CharacterModel].self)
            .eraseToAnyPublisher()
    }
    
    func getImagePublisher(url: String) -> AnyPublisher<Data, NetworkError> {
        let request = ImageRequest(url: url)
        return networkService.networkPublisher(request: request)
            .eraseToAnyPublisher()
    }
    
    func getImagesPublisher(urls: [String]) -> AnyPublisher<[Data], NetworkError> {
        return urls.publisher
            .setFailureType(to: NetworkError.self)
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
