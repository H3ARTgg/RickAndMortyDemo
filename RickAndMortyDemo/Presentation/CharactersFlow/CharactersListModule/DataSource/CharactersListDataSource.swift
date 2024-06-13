import UIKit

final class CharactersListDataSource: UICollectionViewDiffableDataSource<Int, CharactersListCellModel> {
    init(_ collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell: CharactersListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.cellModel = itemIdentifier
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
        if snapshot.numberOfSections == 0 {
            snapshot.appendSections([0])
        }
        snapshot.appendItems(data, toSection: 0)
        apply(snapshot, animatingDifferences: animated)
    }
    
    func reload() {
        var snapshot = snapshot()
        let items = snapshot.itemIdentifiers
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        apply(snapshot, animatingDifferences: true)
    }
}
