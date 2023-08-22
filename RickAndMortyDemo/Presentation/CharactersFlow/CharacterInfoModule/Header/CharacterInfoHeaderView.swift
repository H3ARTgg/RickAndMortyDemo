import UIKit

enum Header {
    case info
    case origin
    case episodes
    
    func getTitle() -> String {
        switch self {
        case .info:
            return .info
        case .origin:
            return .origin
        case .episodes:
            return .episodes
        }
    }
}

final class CharacterInfoHeaderView: UITableViewHeaderFooterView {
    static let identifier = "CharacterInfoHeaderViewIdentifier"
    private let title = UILabel()
    var headerModel: Header? {
        didSet {
            title.text = headerModel?.getTitle()
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTitle() {
        title.textColor = .rmWhite
        title.font = .title17
        
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
    }
}
