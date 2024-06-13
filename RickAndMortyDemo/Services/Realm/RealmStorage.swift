import RealmSwift
import Foundation

// MARK: - StorageProtocol
protocol StorageProtocol: AnyObject {
    var delegate: RealmStorageDelegate? { set get }
    
    func addToFavorite(_ id: Int)
    func removeFromFavorite(_ id: Int)
    func getFavorites() -> [Int]
}

// MARK: - RealmStorageDelegate
protocol RealmStorageDelegate: AnyObject {
    func favoritesChanged()
}

// MARK: - RealmStorage
final class RealmStorage {
    weak var delegate: RealmStorageDelegate?
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

// MARK: - StorageProtocol Extension
extension RealmStorage: StorageProtocol {
    func addToFavorite(_ id: Int) {
        let object = CharacterObject()
        object.characterId = id
        
        try? self.realm.write({
            realm.add(object)
        })
    }
    
    func removeFromFavorite(_ id: Int) {
        guard let characterObject = readData(forType: CharacterObject.self).first(where: { $0.characterId == id }) else { return }
        
        realm.writeAsync({ [weak self] in
            self?.realm.delete(characterObject)
        }, onComplete: { [weak self] _ in
            self?.delegate?.favoritesChanged()
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
