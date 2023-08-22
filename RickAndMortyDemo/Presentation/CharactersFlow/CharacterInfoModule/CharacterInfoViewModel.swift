import Foundation
import Combine

protocol CharacterInfoCoordination {
    var finish: (() -> Void)? { get set }
}

protocol CharacterInfoViewModelProtocol: AnyObject {
    var characterOriginPublisher: AnyPublisher<CharacterOriginModel, NetworkError> { get }
    var episodesPublisher: AnyPublisher<[EpisodeModel], NetworkError> { get }
    var imageData: Data { get }
    var characterModel: CharacterModel { get }
    
    var getOrigin: PassthroughSubject<Void, NetworkError> { get }
    var getEpisodes: PassthroughSubject<Void, NetworkError> { get }
    
    func moveBackToRootViewController()
    func requestCharacterOriginAndEpisodes()
    func makeDataSourceData(characterModel: CharacterModel, origin: CharacterOriginModel, episodes: [EpisodeModel]) -> [SectionData]
}

final class CharacterInfoViewModel: CharacterInfoViewModelProtocol, CharacterInfoCoordination {
    private(set) var characterOriginPublisher: AnyPublisher<CharacterOriginModel, NetworkError>
    private(set) var episodesPublisher: AnyPublisher<[EpisodeModel], NetworkError>
    private(set) var imageData: Data
    private(set) var characterModel: CharacterModel
    
    private(set) var getOrigin = PassthroughSubject<Void, NetworkError>()
    private(set) var getEpisodes = PassthroughSubject<Void, NetworkError>()
    
    var finish: (() -> Void)?
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol, characterModel: CharacterModel, imageData: Data) {
        self.networkManager = networkManager
        self.characterOriginPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
        self.episodesPublisher = Empty(completeImmediately: false).eraseToAnyPublisher()
        self.imageData = imageData
        self.characterModel = characterModel
        
        characterOriginPublisher = getOrigin.flatMap({ [unowned self] _ in
            if characterModel.origin.url == "" {
                let publisher = CurrentValueSubject<CharacterOriginModel, NetworkError>(CharacterOriginModel(id: 1, name: characterModel.origin.name, type: ""))
                return publisher.eraseToAnyPublisher()
            } else {
                return self.networkManager.getCharacterOriginPublisher(url: characterModel.origin.url)
            }
        })
        .eraseToAnyPublisher()
        
        episodesPublisher = getEpisodes.flatMap({ [unowned self] _ in
            if characterModel.episode.count == 1 {
                return self.networkManager.getEpisodePublisher(url: characterModel.episode.first!)
                    .map({ output in
                        [output]
                    })
                    .eraseToAnyPublisher()
            } else {
                return self.networkManager.getEpisodesPublisher(urls: characterModel.episode)
            }
        })
        .eraseToAnyPublisher()
    }
    
    func requestCharacterOriginAndEpisodes() {
        getOrigin.send()
        getEpisodes.send()
    }
    
    func moveBackToRootViewController() {
        finish?()
    }
    
    func makeDataSourceData(characterModel: CharacterModel, origin: CharacterOriginModel, episodes: [EpisodeModel]) -> [SectionData] {
        var sectionData: [SectionData] = []
        var type = characterModel.type
        var originType = origin.type
        if type.isEmpty {
            type = "None"
        }
        if originType.isEmpty {
            originType = "None"
        }
        sectionData.append(SectionData(key: Section.info, values: [
            SectionItem.info(InfoCellModel(species: characterModel.species, type: type, gender: characterModel.gender))]))
        sectionData.append(SectionData(
            key: Section.origin,
            values: [SectionItem.origin(OriginCellModel(originName: characterModel.origin.name, originType: originType))]
        ))
        var sectionItems: [SectionItem] = []
        for episode in episodes {
            let sectionItem = SectionItem.episode(EpisodeModel(
                id: episode.id,
                name: episode.name,
                airDate: episode.airDate,
                episode: makeCorrectEpisodeNumber(episode: episode.episode))
            )
            sectionItems.append(sectionItem)
        }
        sectionData.append(SectionData(
            key: Section.episode,
            values: sectionItems
        ))
        return sectionData
    }
    
    private func makeCorrectEpisodeNumber(episode: String) -> String {
        episode
            .replacingOccurrences(of: "0", with: "")
            .replacingOccurrences(of: "S", with: "Season: ")
            .replacingOccurrences(of: "E", with: ",Episode: ")
            .split(separator: ",")
            .reversed()
            .joined(separator: ", ")

    }
}
