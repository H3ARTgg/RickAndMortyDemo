import Combine
import Foundation
import Moya
import CombineMoya

// MARK: - NetworkManagerProtocol
protocol NetworkManagerProtocol: AnyObject {
    func characters(ids: [Int]) -> AnyPublisher<[CharacterModel], MoyaError>
    func image(url: String) -> AnyPublisher<Data, MoyaError>
    func origin(url: String) -> AnyPublisher<CharacterOriginModel, MoyaError>
    func episodes(urls: [String]) -> AnyPublisher<[EpisodeModel], MoyaError>
    func search(filters: [CharacterSearchType], nextPage: String?) -> AnyPublisher<CharacterSearch, MoyaError>
}

// MARK: - NetworkManager
final class NetworkManager: NetworkManagerProtocol {
    private let provider: MoyaProvider<MultiTarget>
    private let decoder = JSONDecoder()
    
    init(provider: MoyaProvider<MultiTarget> = MoyaProvider<MultiTarget>()) {
        self.provider = provider
    }
    
    func characters(ids: [Int]) -> AnyPublisher<[CharacterModel], MoyaError> {
        if ids.count == 1 {
            return provider.requestPublisher(MultiTarget(RickAndMortyAPI.characters(ids: ids)))
                .map(\.data)
                .decode(type: CharacterModel.self, decoder: decoder)
                .map({ [$0] })
                .mapError { MoyaError.encodableMapping($0) }
                .eraseToAnyPublisher()
        } else {
            return provider.requestPublisher(MultiTarget(RickAndMortyAPI.characters(ids: ids)))
                .map(\.data)
                .decode(type: [CharacterModel].self, decoder: decoder)
                .mapError { MoyaError.encodableMapping($0) }
                .eraseToAnyPublisher()
        }
    }
    
    func image(url: String) -> AnyPublisher<Data, MoyaError> {
        provider.requestPublisher(MultiTarget(RickAndMortyAPI.image(url: url)))
            .map(\.data)
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    func origin(url: String) -> AnyPublisher<CharacterOriginModel, MoyaError> {
        provider.requestPublisher(MultiTarget(RickAndMortyAPI.origin(url: url)))
            .map(\.data)
            .decode(type: CharacterOriginModel.self, decoder: decoder)
            .mapError { MoyaError.encodableMapping($0) }
            .eraseToAnyPublisher()
    }
    
    func episodes(urls: [String]) -> AnyPublisher<[EpisodeModel], MoyaError> {
        if urls.count == 1 {
            return provider.requestPublisher(MultiTarget(RickAndMortyAPI.episodes(urls: urls)))
                .map(\.data)
                .decode(type: EpisodeModel.self, decoder: decoder)
                .map({ [$0] })
                .mapError { MoyaError.encodableMapping($0) }
                .eraseToAnyPublisher()
        } else {
            return provider.requestPublisher(MultiTarget(RickAndMortyAPI.episodes(urls: urls)))
                .map(\.data)
                .decode(type: [EpisodeModel].self, decoder: decoder)
                .mapError { MoyaError.encodableMapping($0) }
                .eraseToAnyPublisher()
        }
    }
    
    func search(filters: [CharacterSearchType], nextPage: String?) -> AnyPublisher<CharacterSearch, MoyaError> {
        let target: MultiTarget
        if let nextPage {
            target = MultiTarget(RickAndMortyAPI.nextSearch(nextPage: nextPage))
        } else {
            target = MultiTarget(RickAndMortyAPI.search(filters: filters))
        }
        
        return provider.requestPublisher(target)
            .map(\.data)
            .decode(type: CharacterSearch.self, decoder: decoder)
            .mapError { MoyaError.encodableMapping($0) }
            .eraseToAnyPublisher()
    }
}
