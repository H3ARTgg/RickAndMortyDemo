protocol CharactersListCoordination {
    var finish: (() -> Void)? { get set }
    var headForCharacterInfo: (() -> Void)? { get set }
}

protocol CharactersListViewModelProtocol: AnyObject {
    
}


final class CharactersListViewModel: CharactersListViewModelProtocol & CharactersListCoordination {
    var finish: (() -> Void)?
    var headForCharacterInfo: (() -> Void)?
}
