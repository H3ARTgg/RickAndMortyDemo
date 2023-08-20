import Foundation

enum LocalizedKeys: String {
    case characters = "characters"
}

extension String {
    static let characters = NSLocalizedString(LocalizedKeys.characters.rawValue, comment: "")
}
