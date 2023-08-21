import Combine
import Foundation

protocol NetworkManagerProtocol: AnyObject {
    func getCharactersPublisher(characterIdsRange: Range<Int>) -> AnyPublisher<[CharacterModel], NetworkError>
    func getImagesPublisher(urls: [String]) -> AnyPublisher<[Data], NetworkError>
    func getImagePublisher(url: String) -> AnyPublisher<Data, NetworkError>
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
    }
    
    func getImagesPublisher(urls: [String]) -> AnyPublisher<[Data], NetworkError> {
        return urls.publisher
            .setFailureType(to: NetworkError.self)
            .flatMap(getImagePublisher)
            .collect()
            .eraseToAnyPublisher()
    }
}
