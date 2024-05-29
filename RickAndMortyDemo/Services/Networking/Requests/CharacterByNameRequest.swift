import Foundation

struct CharacterByNameRequest: NetworkRequest {
    var endpoint: URL?
    
    init(name: String) {
        self.endpoint = URL(string: "https://rickandmortyapi.com/api/character/" + "?name=" + name)
    }
}
