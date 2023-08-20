protocol ModulesFactoryProtocol: AnyObject {
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination)
    //func makeCharacterInfoView() -> (view: Presentable, coordination: CharacterInfoCoordination)
}

final class ModulesFactory: ModulesFactoryProtocol {
    func makeCharactersListView() -> (view: Presentable, coordination: CharactersListCoordination) {
        let listVM = CharactersListViewModel()
        let list = CharactersListViewController(viewModel: listVM)
        return (list, listVM)
    }
    
    //func makeCharacterInfoView() -> (view: Presentable, coordination: CharacterInfoCoordination) {
    //}
}
