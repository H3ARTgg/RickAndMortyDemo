import Foundation

enum LocalizedKeys: String {
    case characters = "characters"
    
    case info = "info"
    case origin = "origin"
    case episodes = "episodes"
    
    case species = "species"
    case type = "type"
    case gender = "gender"
    
    case unknown = "unknown"
    case none = "none"
    
    case alive = "alive"
    case dead = "dead"
    
    case male = "male"
    case female = "female"
    
    case human = "human"
    case alien = "alien"
    case animal = "animal"
    case humanoid = "humanoid"
    case mythologicalCreature = "mythological_creature"
    case disease = "disease"

    case parasite = "parasite"
    case dog = "dog"
    case birdPerson = "bird_person"
    case organicGun = "organic_gun"
    case giant = "giant"
}

extension String {
    // Characters Screen
    static let characters = NSLocalizedString(LocalizedKeys.characters.rawValue, comment: "")
    
    // Headers - CharacterInfo Screen
    static let info = NSLocalizedString(LocalizedKeys.info.rawValue, comment: "")
    static let origin = NSLocalizedString(LocalizedKeys.origin.rawValue, comment: "")
    static let episodes = NSLocalizedString(LocalizedKeys.episodes.rawValue, comment: "")
    
    // Lines - CharacterInfo Screen
    static let species = NSLocalizedString(LocalizedKeys.species.rawValue, comment: "")
    static let type = NSLocalizedString(LocalizedKeys.type.rawValue, comment: "")
    static let gender = NSLocalizedString(LocalizedKeys.gender.rawValue, comment: "")
    
    // Other
    static let unknown = NSLocalizedString(LocalizedKeys.unknown.rawValue, comment: "")
    static let none = NSLocalizedString(LocalizedKeys.none.rawValue, comment: "")
    
    // Status
    static let alive = NSLocalizedString(LocalizedKeys.alive.rawValue, comment: "")
    static let dead = NSLocalizedString(LocalizedKeys.dead.rawValue, comment: "")
    
    // Gender
    static let male = NSLocalizedString(LocalizedKeys.male.rawValue, comment: "")
    static let female = NSLocalizedString(LocalizedKeys.female.rawValue, comment: "")
    
    // Species
    static let human = NSLocalizedString(LocalizedKeys.human.rawValue, comment: "")
    static let alien = NSLocalizedString(LocalizedKeys.alien.rawValue, comment: "")
    static let animal = NSLocalizedString(LocalizedKeys.animal.rawValue, comment: "")
    static let humanoid = NSLocalizedString(LocalizedKeys.humanoid.rawValue, comment: "")
    static let mythologicalCreature = NSLocalizedString(LocalizedKeys.mythologicalCreature.rawValue, comment: "")
    static let disease = NSLocalizedString(LocalizedKeys.disease.rawValue, comment: "")
    static let speciesArray = [human, alien, animal, humanoid, mythologicalCreature, disease, unknown]
    
    // Type
    static let parasite = NSLocalizedString(LocalizedKeys.parasite.rawValue, comment: "")
    static let dog = NSLocalizedString(LocalizedKeys.dog.rawValue, comment: "")
    static let birdPerson = NSLocalizedString(LocalizedKeys.birdPerson.rawValue, comment: "")
    static let organicGun = NSLocalizedString(LocalizedKeys.organicGun.rawValue, comment: "")
    static let giant = NSLocalizedString(LocalizedKeys.giant.rawValue, comment: "")
    static let typesArray = [parasite, dog, birdPerson, organicGun, giant, unknown]
}
