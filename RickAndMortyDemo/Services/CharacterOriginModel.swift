struct CharacterOriginModel: Codable, Hashable {
    let id: Int
    let name: String
    let type: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
