struct CharacterModel: Codable, Hashable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: Origin
    let image: String
    let episode: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CharacterModel, rhs: CharacterModel) -> Bool {
        lhs.id == rhs.id
    }
}

struct Origin: Codable {
    let name: String
    let url: String
}
