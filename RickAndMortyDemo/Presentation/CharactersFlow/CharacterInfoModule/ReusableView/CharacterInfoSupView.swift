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
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .title17
        return label
    }()
    var headerModel: Header? {
        didSet {
            titleLabel.text = headerModel?.getTitle()
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        fill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Initial UI setup
    private func fill() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-16)
            make.horizontalEdges.equalToSuperview()
        }
    }
}
