import Foundation

struct ImageRequest: NetworkRequest {
    var endpoint: URL?
    
    init(url: String) {
        self.endpoint = URL(string: url)
    }
}
