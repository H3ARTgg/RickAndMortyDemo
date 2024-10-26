// MARK: - CharacterSearchType
enum CharacterSearchType: CaseIterable {
    case name(name: String)
    case status(status: CharacterStatus)
    case species(species: String)
    case type(type: String)
    case gender(gender: CharacterGender)
    
    static var allCases: [CharacterSearchType] {
        [.name(name: ""), .status(status: .alive), .species(species: ""), .type(type: ""), .gender(gender: .male)]
    }
    
    var title: String {
        switch self {
        case .name:
            return "Name"
        case .status:
            return "Status"
        case .species:
            return "Species"
        case .type:
            return "Type"
        case .gender:
            return "Gender"
        }
    }
    
    var searchPlaceholder: String {
        switch self {
        case .name:
            return "Search by name"
        case .species:
            return "Search by species"
        case .type:
            return "Search by type"
        case .gender, .status:
            return ""
        }
    }
}

// MARK: - CharacterStatus
enum CharacterStatus: String {
    case alive, dead, unknown
    
    var title: String {
        rawValue.capitalized
    }
}

// MARK: - CharacterGender
enum CharacterGender: String {
    case female, male, genderless
    
    var title: String {
        rawValue.capitalized
    }
}

// MARK: - CharacterSearch
struct CharacterSearch: Codable, Hashable {
    let info: Info
    let results: [CharacterModel]
}

// MARK: - Info
struct Info: Codable, Hashable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
