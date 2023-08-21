import UIKit

protocol DiffableDataSourceDelegate: AnyObject {
    func showActivityIndicator()
    func removeActivityIndicator()
}

final class CharactersListDataSource: UICollectionViewDiffableDataSource<Int, CharactersListCellModel> {
    private var snapshot = NSDiffableDataSourceSnapshot<Int, CharactersListCellModel>()
    
    init(_ collectionView: UICollectionView, _ viewModel: CharactersListViewModelProtocol, _ delegate: DiffableDataSourceDelegate) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell: CharactersListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            let newItemIdentifier = CharactersListCellModel(id: itemIdentifier.id, name: itemIdentifier.name, imageData: itemIdentifier.imageData, rowNumber: indexPath.row)
            cell.cellModel = newItemIdentifier
            
            if indexPath.row == viewModel.getCharactersCount() - 1 {
                delegate.showActivityIndicator()
                viewModel.requestCharacters()
            }
            return cell
        }
    }
    
    func reload(_ data: [CharactersListCellModel], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(data, toSection: 0)
        apply(snapshot, animatingDifferences: animated)
    }
}
