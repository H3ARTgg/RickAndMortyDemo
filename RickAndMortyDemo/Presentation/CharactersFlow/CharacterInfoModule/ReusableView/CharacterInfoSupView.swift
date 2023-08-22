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

final class CharacterInfoSupView: UICollectionReusableView {
    static let identifier = "Header"
    private let title = UILabel()
    var headerModel: Header? {
        didSet {
            title.text = headerModel?.getTitle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTitle() {
        title.textColor = .rmWhite
        title.font = .title17
        
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
