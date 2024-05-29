struct CharacterByNameModel: Codable, Hashable {
    let info: Info
    let results: [CharacterModel]
}

struct Info: Codable, Hashable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
