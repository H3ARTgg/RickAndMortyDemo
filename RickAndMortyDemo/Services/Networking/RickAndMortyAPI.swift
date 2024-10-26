import Foundation
import Moya

enum RickAndMortyAPI {
    case characters(ids: [Int])
    case image(url: String)
    case origin(url: String)
    case episodes(urls: [String])
    case search(filter: CharacterSearchType)
    case nextSearch(nextPage: String)
}

extension RickAndMortyAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .image(let urlString), .origin(let urlString):
            return URL(string: urlString)!
        case .search(let filter):
            switch filter {
            case .name(let name):
                return URL(string: "https://rickandmortyapi.com/api/character/?name=\(name)")!
            case .status(let status):
                return URL(string: "https://rickandmortyapi.com/api/character/?status=\(status.rawValue)")!
            case .species(let species):
                return URL(string: "https://rickandmortyapi.com/api/character/?species=\(species)")!
            case .type(let type):
                return URL(string: "https://rickandmortyapi.com/api/character/?type=\(type)")!
            case .gender(let gender):
                return URL(string: "https://rickandmortyapi.com/api/character/?gender=\(gender.rawValue)")!
            }
        case .nextSearch(let page):
            return URL(string: page)!
        case _:
            return URL(string: "https://rickandmortyapi.com/api")!
        }
    }
    
    var path: String {
        switch self {
        case .characters(let ids):
            return "/character/" + makeStringOfArray(ids)
        case .episodes(let urls):
            return "/episode/" + makeEpisodesString(urls)
        case _:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case _:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case _:
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        switch self {
        case .characters:
            return mock(for: "characters")
        case .image:
            return mock(for: "image", with: "jpeg")
        case .origin:
            return mock(for: "origin")
        case .episodes:
            return mock(for: "episodes")
        case .search:
            return mock(for: "character")
        case .nextSearch:
            return mock(for: "character")
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}

extension RickAndMortyAPI {
    private func makeStringOfArray(_ array: [Int]) -> String {
        array.sorted().map { String($0) }.joined(separator: ",")
    }
    private func makeEpisodesString(_ episodes: [String]) -> String {
        episodes
            .map {
                $0.replacingOccurrences(
                of: "https://rickandmortyapi.com/api/episode/",
                with: ""
            )}
            .joined(separator: ",")
    }
    
    private func mock(for name: String, with extens: String = "json") -> Data {
        guard let url = Bundle.main.url(forResource: name, withExtension: extens),
              let data = try? Data(contentsOf: url) else {
            return Data()
        }
        return data
    }
}
