import Foundation

struct CharacterOriginRequest: NetworkRequest {
    var endpoint: URL?
    
    init(url: String) {
        endpoint = URL(string: url)
    }
}
