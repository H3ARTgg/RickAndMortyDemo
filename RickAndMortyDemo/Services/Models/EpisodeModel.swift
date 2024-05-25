import Foundation

struct EpisodeModel: Codable, Hashable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case airDate = "air_date"
        case episode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    static func == (lhs: EpisodeModel, rhs: EpisodeModel) -> Bool {
        return lhs.id == rhs.id || lhs.name == rhs.name
    }
}
