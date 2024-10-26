import Foundation
import Moya

enum RickAndMortyAPI {
    case characters(ids: [Int])
    case image(url: String)
    case origin(url: String)
    case episodes(urls: [String])
    case characterByName(name: String)
}

extension RickAndMortyAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .image(let urlString), .origin(let urlString):
            return URL(string: urlString)!
        case .characterByName(let name):
            return URL(string: "https://rickandmortyapi.com/api/character/?name=\(name)")!
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
        case .characterByName(_):
            return ""
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
        case .characterByName:
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
