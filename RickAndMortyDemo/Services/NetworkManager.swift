import Combine
import Foundation

protocol NetworkManagerProtocol: AnyObject {
    func getCharactersPublisher(characterIds: [Int]) -> AnyPublisher<[CharacterModel], NetworkError>
    func getImagesPublisher(urls: [String]) -> AnyPublisher<[Data], NetworkError>
    func getImagePublisher(url: String) -> AnyPublisher<Data, NetworkError>
    func getCharacterOriginPublisher(url: String) -> AnyPublisher<CharacterOriginModel, NetworkError>
    func getEpisodesPublisher(urls: [String]) -> AnyPublisher<[EpisodeModel], NetworkError>
    func getCharactersByName(name: String) -> AnyPublisher<CharacterByNameModel, NetworkError>
}

final class NetworkManager: NetworkManagerProtocol {
    private let networkService: NetworkClient
    
    init(networkService: NetworkClient) {
        self.networkService = networkService
    }
    
    func getCharactersPublisher(characterIds: [Int]) -> AnyPublisher<[CharacterModel], NetworkError> {
        let request = CharactersRequest(characterIds)
        if characterIds.count == 1 {
            return networkService.networkPublisher(request: request, type: CharacterModel.self)
                .compactMap({ [$0] })
                .eraseToAnyPublisher()
        } else {
            return networkService.networkPublisher(request: request, type: [CharacterModel].self)
                .eraseToAnyPublisher()
        }
    }
    
    func getImagePublisher(url: String) -> AnyPublisher<Data, NetworkError> {
        let request = ImageRequest(url: url)
        return networkService.networkPublisher(request: request)
            .eraseToAnyPublisher()
    }
    
    func getImagesPublisher(urls: [String]) -> AnyPublisher<[Data], NetworkError> {
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
        if urls.count == 1 {
            return networkService.networkPublisher(request: request, type: EpisodeModel.self)
                .map({ [$0] })
                .eraseToAnyPublisher()
        } else {
            return networkService.networkPublisher(request: request, type: [EpisodeModel].self)
                .eraseToAnyPublisher()
        }
    }
    
    func getCharactersByName(name: String) -> AnyPublisher<CharacterByNameModel, NetworkError> {
        let request = CharacterByNameRequest(name: name)
        return networkService.networkPublisher(request: request, type: CharacterByNameModel.self)
            .eraseToAnyPublisher()
    }
}
