protocol CharacterInfoCoordination {
    var finish: (() -> Void)? { get set }
}

protocol CharacterInfoViewModelProtocol: AnyObject {
    
}

final class CharacterInfoViewModel: CharacterInfoViewModelProtocol & CharacterInfoCoordination {
    var finish: (() -> Void)?
    
}
