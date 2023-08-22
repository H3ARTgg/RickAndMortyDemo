import UIKit

enum Section: Hashable {
    case info
    case origin
    case episode
}

enum SectionItem: Hashable {
    case info(InfoCellModel)
    case origin(OriginCellModel)
    case episode(EpisodeCellModel)
}

struct SectionData: Hashable {
    let key: Section
    let values: [SectionItem]
}


final class CharacterInfoDataSource: UITableViewDiffableDataSource<Section, SectionItem> {
    private var snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()
    
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .info(let model):
                let cell: InfoCell = tableView.dequeueReusableCell()
                cell.cellModel = model
                return cell
            case .origin(let model):
                let cell: OriginCell = tableView.dequeueReusableCell()
                cell.cellModel = model
                return cell
            case .episode(let model):
                let cell: EpisodeCell = tableView.dequeueReusableCell()
                return cell
            }
        }
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
