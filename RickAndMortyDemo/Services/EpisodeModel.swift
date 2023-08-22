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
    }
}
