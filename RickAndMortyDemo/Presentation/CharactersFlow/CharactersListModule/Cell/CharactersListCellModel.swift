import Foundation

struct CharactersListCellModel: Hashable {
    let id: UUID
    let name: String
    let imageData: Data
    var rowNumber: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
