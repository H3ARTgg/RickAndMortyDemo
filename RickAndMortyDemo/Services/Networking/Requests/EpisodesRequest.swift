import Foundation

struct EpisodesRequest: NetworkRequest {
    var endpoint: URL?
    
    init(episodes: [String]) {
        endpoint = URL(string: "https://rickandmortyapi.com/api/episode/" + makeEpisodesString(episodes))
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
}
