import UIKit

enum Section: Hashable {
    case info
    case origin
    case episode
}

enum SectionItem: Hashable {
    case info(InfoCellModel)
    case origin(OriginCellModel)
    case episode(EpisodeModel)
}

struct SectionData: Hashable {
    let key: Section
    let values: [SectionItem]
}


final class CharacterInfoDataSource: UICollectionViewDiffableDataSource<Section, SectionItem> {
    private var snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()
    
    init(_ collectionView: UICollectionView) {
        super.init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .info(let model):
                let cell: InfoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.cellModel = model
                return cell
            case .origin(let model):
                let cell: OriginCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.cellModel = model
                return cell
            case .episode(let model):
                let cell: EpisodeCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.cellModel = model
                return cell
            }
        })
    }
                   
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "Header"
        case UICollectionView.elementKindSectionFooter:
            id = "Footer"
        default:
            id = ""
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? CharacterInfoSupView else {
            assertionFailure("No SupplementaryView")
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
