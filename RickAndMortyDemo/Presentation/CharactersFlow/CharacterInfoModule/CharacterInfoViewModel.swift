import Foundation
import Combine

// MARK: - CharacterInfoCoordination Protocol
protocol CharacterInfoCoordination: AnyObject {
    /// Callback for exit from screen
    var finish: (() -> Void)? { get set }
}

// MARK: - CharacterInfoViewModelProtocol
protocol CharacterInfoViewModelProtocol: AnyObject {
    /// Publishes character origin, where origin.name == "Error" is Error
    var characterOriginPublisher: AnyPublisher<CharacterOriginModel, Never> { get }
    /// Publishes character episodes, where empty array is Error
    var episodesPublisher: AnyPublisher<[EpisodeModel], Never> { get }
    var errorPublisher: AnyPublisher<NetworkError, Never> { get }
    
    /// Returns CharacterModel and Image Data
    func getCharactersInfo() -> (model: CharacterModel, imageData: Data)
    /// Moving back to CharactersList Screen
    func moveBackToRootViewController()
    /// Requesting character origin and episodes
    func requestCharacterOriginAndEpisodes()
    /// Making array for updating CharacterInfoDataSource
    func makeDataSourceData(characterModel: CharacterModel, origin: CharacterOriginModel, episodes: [EpisodeModel]) -> [SectionData]
}

// MARK: - CharacterInfoViewModel
final class CharacterInfoViewModel: CharacterInfoViewModelProtocol, CharacterInfoCoordination {
    /// Callback for exit from screen
    var finish: (() -> Void)?
    
    /// Publishes character origin, where origin.name == "Error" is Error
    private let characterOriginSubject = PassthroughSubject<CharacterOriginModel, Never>()
    var characterOriginPublisher: AnyPublisher<CharacterOriginModel, Never> {
        characterOriginSubject.eraseToAnyPublisher()
    }
    
    /// Publishes character episodes, where empty array is Error
    private let episodesSubject = PassthroughSubject<[EpisodeModel], Never>()
    var episodesPublisher: AnyPublisher<[EpisodeModel], Never> {
        episodesSubject.eraseToAnyPublisher()
    }
    
    private let errorSubject = PassthroughSubject<NetworkError, Never>()
    var errorPublisher: AnyPublisher<NetworkError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    private let networkManager: NetworkManagerProtocol
    private let characterModel: CharacterModel
    private let imageData: Data
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(networkManager: NetworkManagerProtocol, characterModel: CharacterModel, imageData: Data) {
        self.networkManager = networkManager
        self.characterModel = characterModel
        self.imageData = imageData
    }
    
    /// Requesting character origin and episodes
    func requestCharacterOriginAndEpisodes() {
        requestCharacterOrigin()
        requestCharacterEpisodes()
    }
    
    /// Request character origin
    private func requestCharacterOrigin() {
        if characterModel.origin.url.isEmpty {
            characterOriginSubject.send(CharacterOriginModel(id: 1, name: characterModel.origin.name, type: ""))
        } else {
            networkManager.getCharacterOriginPublisher(url: characterModel.origin.url)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        self.errorSubject.send(error)
                    }
                }, receiveValue: { [weak self] origin in
                    guard let self else { return }
                    self.characterOriginSubject.send(origin)
                })
                .store(in: &cancellables)
        }
    }
    
    /// Request character episodes
    private func requestCharacterEpisodes() {
        networkManager.getEpisodesPublisher(urls: characterModel.episode)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.errorSubject.send(error)
                }
            }, receiveValue: { [weak self] episodes in
                guard let self else { return }
                self.episodesSubject.send(episodes)
            })
            .store(in: &cancellables)
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
    func makeDataSourceData(characterModel: CharacterModel, origin: CharacterOriginModel, episodes: [EpisodeModel]) -> [SectionData] {
        var sectionData: [SectionData] = []
        
        let type = characterModel.type.isEmpty ? String.none : characterModel.type
        let originType = origin.type.isEmpty ? String.none : origin.type
        
        // Info section
        sectionData.append(SectionData(
            key: .info,
            values: [SectionItem.info(InfoCellModel(
                species: characterModel.species,
                type: type,
                gender: checkForLocalization(gender: characterModel.gender)
            ))]
        ))
        
        // Origin section
        sectionData.append(SectionData(
            key: .origin,
            values: [SectionItem.origin(OriginCellModel(
                originName: characterModel.origin.name,
                originType: originType
            ))]
        ))
        
        // Episodes section
        let sectionItems = episodes.map { episode in
            SectionItem.episode(EpisodeModel(
                id: episode.id,
                name: episode.name,
                airDate: episode.airDate,
                episode: makeCorrectEpisodeNumber(episode: episode.episode)
            ))
        }
        sectionData.append(SectionData(key: .episode, values: sectionItems))
        
        return sectionData
    }
    
    /// Converts received episode name to appearing format
    private func makeCorrectEpisodeNumber(episode: String) -> String {
        episode
            .replacingOccurrences(of: "S", with: "Season: ")
            .replacingOccurrences(of: "E", with: ", Episode: ")
            .split(separator: ",")
            .reversed()
            .map {
                $0.contains("Episode: 0") || $0.contains("Season: 0") ? $0.replacingOccurrences(of: "0", with: "") : String($0)
            }
            .joined(separator: ", ")
    }
    
    /// Checks for localization for gender
    private func checkForLocalization(gender: String) -> String {
        switch gender {
        case "Male":
            return .male
        case "Female":
            return .female
        case "unknown":
            return .unknown
        default:
            return gender
        }
    }
}
