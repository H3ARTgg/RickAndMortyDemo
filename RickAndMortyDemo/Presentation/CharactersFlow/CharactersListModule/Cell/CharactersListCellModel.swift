import Foundation

// MARK: - CharactersListCellModel
final class CharactersListCellModel {
    // MARK: - Properties
    var isLiked: Bool {
        get {
            storage.getFavorites().contains(characterId)
        } set {
            newValue ? storage.addToFavorite(characterId) : storage.removeFromFavorite(characterId)
        }
    }
    let id = UUID()
    let characterId: Int
    let name: String
    let imageData: Data
    private let storage: StorageProtocol
    
    // MARK: - Init
    init(characterId: Int, name: String, imageData: Data, storage: StorageProtocol) {
        self.characterId = characterId
        self.name = name
        self.imageData = imageData
        self.storage = storage
    }
}

// MARK: - Hashable
extension CharactersListCellModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    static func == (lhs: CharactersListCellModel, rhs: CharactersListCellModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
