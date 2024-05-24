import UIKit

final class CharactersListDataSource: UICollectionViewDiffableDataSource<Int, CharactersListCellModel> {
    init(_ collectionView: UICollectionView, _ viewModel: CharactersListViewModelProtocol) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell: CharactersListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            let newItemIdentifier = CharactersListCellModel(id: itemIdentifier.id, name: itemIdentifier.name, imageData: itemIdentifier.imageData, rowNumber: indexPath.row)
            cell.cellModel = newItemIdentifier
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
    
    func add(_ data: [CharactersListCellModel], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.appendItems(data, toSection: 0)
        apply(snapshot, animatingDifferences: animated)
    }
}
