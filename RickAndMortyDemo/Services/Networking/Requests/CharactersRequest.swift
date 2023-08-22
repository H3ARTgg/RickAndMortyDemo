import Foundation

struct CharactersRequest: NetworkRequest {
    var endpoint: URL?
    
    init(_ characterIdsRange: Range<Int>) {
        self.endpoint = URL(string: "https://rickandmortyapi.com/api/character/" + makeStringOfRange(characterIdsRange))
    }
    
    private func makeStringOfRange(_ range: Range<Int>) -> String {
        range.sorted().map { String($0) }.joined(separator: ",")
    }
}
