import Foundation
import Combine

// MARK: - CharacterInfoCoordination Protocol
protocol CharacterInfoCoordination {
    /// Callback for exit from screen
    var finish: (() -> Void)? { get set }
}

// MARK: - CharacterInfoViewModelProtocol
protocol CharacterInfoViewModelProtocol: AnyObject {
    /// Publishes character origin, where origin.name == "Error" is Error
    var characterOriginPublisher: AnyPublisher<CharacterOriginModel, Never> { get }
    /// Publishes character episodes, where empty array is Error
    var episodesPublisher: AnyPublisher<[EpisodeModel], Never> { get }
    
    /// Returns CharacterModel and Image Data
    func getCharactersInfo() -> (model: CharacterModel, imageData: Data)
    /// Moving back to CharactersList Screen
    func moveBackToRootViewController()
    /// Requesting character origin and episodes
    func requestCharacterOriginAndEpisodes()
    /// Making array for updating CharacterInfoDataSource
    func makeDataSourceData(
        characterModel: CharacterModel,
        origin: CharacterOriginModel,
        episodes: [EpisodeModel]
    ) -> [SectionData]
}

// MARK: - CharacterInfoViewModel
final class CharacterInfoViewModel: CharacterInfoViewModelProtocol, CharacterInfoCoordination {
    /// Callback for exit from screen
    var finish: (() -> Void)?
    
    /// Publishes character origin, where origin.name == "Error" is Error
    private(set) var characterOriginPublisher: AnyPublisher<CharacterOriginModel, Never>
    /// Publishes character episodes, where empty array is Error
    private(set) var episodesPublisher: AnyPublisher<[EpisodeModel], Never>
    
    private let getOrigin = PassthroughSubject<Void, Never>()
    private let getEpisodes = PassthroughSubject<Void, Never>()
    private let networkManager: NetworkManagerProtocol
    private let characterModel: CharacterModel
    private let imageData: Data
    
    // MARK: - Init
    init(
        networkManager: NetworkManagerProtocol,
        characterModel: CharacterModel,
        imageData: Data
    ) {
        self.networkManager = networkManager
        self.imageData = imageData
        self.characterModel = characterModel
        
        // first init
        characterOriginPublisher = Empty(completeImmediately: false)
            .eraseToAnyPublisher()
        episodesPublisher = Empty(completeImmediately: false)
            .eraseToAnyPublisher()
        
        // triggers to request
        characterOriginPublisher = getOrigin.flatMap({ [unowned self] _ in
            if characterModel.origin.url == "" {
                let publisher = CurrentValueSubject<CharacterOriginModel, Never>(CharacterOriginModel(id: 1, name: characterModel.origin.name, type: ""))
                return publisher
                    .eraseToAnyPublisher()
            } else {
                return self.networkManager.getCharacterOriginPublisher(url: characterModel.origin.url)
                    .eraseToAnyPublisher()
            }
        })
        .eraseToAnyPublisher()
        
        episodesPublisher = getEpisodes.flatMap({ [unowned self] _ in
            self.networkManager.getEpisodesPublisher(urls: characterModel.episode)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    /// Requesting character origin and episodes
    func requestCharacterOriginAndEpisodes() {
        getOrigin.send()
        getEpisodes.send()
    }
    
    /// Returns CharacterModel and Image Data
    func getCharactersInfo() -> (model: CharacterModel, imageData: Data) {
        (characterModel, imageData)
    }
    
    /// Moving back to CharactersList Screen
    func moveBackToRootViewController() {
        finish?()
    }
    
    /// Making array for updating CharacterInfoDataSource
    func makeDataSourceData(
        characterModel: CharacterModel,
        origin: CharacterOriginModel,
        episodes: [EpisodeModel]
    ) -> [SectionData] {
        var sectionData: [SectionData] = []
        var type = characterModel.type
        var originType = origin.type
        
        if type.isEmpty {
            type = String.none
        }
        if originType.isEmpty {
            originType = String.none
        }
        // for info section
        sectionData.append(SectionData(
            key: Section.info, 
            values: [SectionItem.info(InfoCellModel(species: characterModel.species, type: type, gender:  checkForLocalization(gender: characterModel.gender)))]
        ))
        // for origin section
        sectionData.append(SectionData(
            key: Section.origin,
            values: [SectionItem.origin(OriginCellModel(originName: characterModel.origin.name, originType: originType))]
        ))
        // for episode section
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
    
    /// Converts received episode name to appearing format
    private func makeCorrectEpisodeNumber(episode: String) -> String {
        episode
            .replacingOccurrences(of: "S", with: "Season: ")
            .replacingOccurrences(of: "E", with: ",Episode: ")
            .split(separator: ",")
            .reversed()
            .map({
                if String($0).contains("Episode: 0") || String($0).contains("Season: 0") {
                    let new = $0.replacingOccurrences(of: "0", with: "")
                    return new
                } else {
                    return String($0)
                }
            })
            .joined(separator: ", ")
    }
    
    /// Is got localization for gender
    private func checkForLocalization(gender: String) -> String {
        if gender == "Male" {
            return .male
        } else if gender == "Female" {
            return .female
        } else if gender == "unknown" {
            return .unknown
        }
        return gender
    }
}
