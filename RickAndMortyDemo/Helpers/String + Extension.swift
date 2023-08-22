import Foundation

enum LocalizedKeys: String {
    case characters = "characters"
    case info = "info"
    case origin = "origin"
    case episodes = "episodes"
}

extension String {
    static let characters = NSLocalizedString(LocalizedKeys.characters.rawValue, comment: "")
    static let info = NSLocalizedString(LocalizedKeys.info.rawValue, comment: "")
    static let origin = NSLocalizedString(LocalizedKeys.origin.rawValue, comment: "")
    static let episodes = NSLocalizedString(LocalizedKeys.episodes.rawValue, comment: "")
}
