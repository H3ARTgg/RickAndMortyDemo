struct CharacterOriginModel: Codable, Hashable {
    let id: Int
    let name: String
    let type: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    static func == (lhs: CharacterOriginModel, rhs: CharacterOriginModel) -> Bool {
        return lhs.id == rhs.id || lhs.name == rhs.name
    }
}
