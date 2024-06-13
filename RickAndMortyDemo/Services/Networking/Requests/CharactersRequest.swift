import Foundation

struct CharactersRequest: NetworkRequest {
    var endpoint: URL?
    
    init(_ characterIds: [Int]) {
        self.endpoint = URL(string: "https://rickandmortyapi.com/api/character/" + makeStringOfArray(characterIds))
    }
    
    private func makeStringOfArray(_ array: [Int]) -> String {
        array.sorted().map { String($0) }.joined(separator: ",")
    }
}
