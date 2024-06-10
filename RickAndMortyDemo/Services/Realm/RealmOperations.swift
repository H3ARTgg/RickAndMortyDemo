import RealmSwift
import Foundation

// MARK: - RealmOperationsProtocol
protocol StorageProtocol: AnyObject {
    func addToFavorite(_ id: Int)
    func removeFromFavorite(_ id: Int)
    func getFavorites() -> [Int]
}

// MARK: - RealmOperations
final class RealmStorage: StorageProtocol {
    private let realm = try! Realm()
    
    private func readData<T: Object>(forType: T.Type = T.self) -> [T]  {
        var object = realm.objects(T.self).toArray()
        object.reverse()
        return object
    }
    
    private func removeAll<T: Object>(forType: T.Type) {
        let objects = readData(forType: T.self)
        try? self.realm.write {
            realm.delete(objects)
        }
    }
}

// MARK: - CharacterObject
extension RealmStorage {
    func addToFavorite(_ id: Int) {
        let object = CharacterObject()
        object.characterId = id
        
        try? self.realm.write({
            realm.add(object)
        })
    }
    
    func removeFromFavorite(_ id: Int) {
        guard let characterObject = readData(forType: CharacterObject.self).first(where: { $0.characterId == id }) else { return }
        
        try? self.realm.write({
            realm.delete(characterObject)
        })
    }
    
    func getFavorites() -> [Int] {
        readData(forType: CharacterObject.self).map { $0.characterId }
    }
}

// MARK: - Results Extension
extension Results {
    func toArray() -> [Element] {
        return compactMap { $0 }
    }
}
