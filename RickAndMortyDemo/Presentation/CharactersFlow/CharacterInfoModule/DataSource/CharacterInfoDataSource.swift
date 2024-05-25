import UIKit

// MARK: - Section
enum Section: Hashable {
    case info
    case origin
    case episode
}

// MARK: - SectionItem
enum SectionItem: Hashable {
    case info(InfoCellModel)
    case origin(OriginCellModel)
    case episode(EpisodeModel)
}

// MARK: - SectionData
struct SectionData: Hashable {
    let key: Section
    let values: [SectionItem]
}

// MARK: - CharacterInfoDataSource
final class CharacterInfoDataSource: UICollectionViewDiffableDataSource<Section, SectionItem> {
    init(_ collectionView: UICollectionView) {
        super.init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
                // if info section
            case .info(let model):
                let cell: InfoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.cellModel = model
                return cell
                // if origin section
            case .origin(let model):
                let cell: OriginCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.cellModel = model
                return cell
                // if episode section
            case .episode(let model):
                let cell: EpisodeCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.cellModel = model
                return cell
            }
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let id = "Header"
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? CharacterInfoSupView else {
            return UICollectionReusableView(frame: .zero)
        }
        switch indexPath.section {
        case 0:
            view.headerModel = Header.info
        case 1:
            view.headerModel = Header.origin
        case 2:
            view.headerModel = Header.episodes
        default:
            return UICollectionReusableView()
        }
        return view
    }
    
    /// Reloading rows by SectionData array
    func reload(_ data: [SectionData], animated: Bool = true) {
        var snapshot = snapshot()
        snapshot.deleteAllItems()
        for item in data {
            snapshot.appendSections([item.key])
            snapshot.appendItems(item.values, toSection: item.key)
        }
        apply(snapshot, animatingDifferences: animated)
    }
}
