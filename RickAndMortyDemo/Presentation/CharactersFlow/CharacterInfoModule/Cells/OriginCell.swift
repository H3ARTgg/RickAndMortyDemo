import UIKit

struct OriginCellModel: Hashable {
    let originName: String
    let originType: String
}

final class OriginCell: UICollectionViewCell, ReuseIdentifying, Identifiable {
    private let originName = UILabel()
    private let originType = UILabel()
    private let containerView = UIView()
    private let planetImageView = UIImageView()
    var cellModel: OriginCellModel? {
        didSet {
            guard let cellModel else { return }
            originName.text = cellModel.originName
            originType.text = cellModel.originType
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private func configure() {
        contentView.backgroundColor = .rmBlackSecondary
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
        
        originName.textColor = .rmWhite
        originName.font = .title17
        originName.numberOfLines = 0
        
        originType.textColor = .rmGreen
        originType.font = .regular13
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = .rmBlack2
        
        planetImageView.image = UIImage(named: Consts.planet) ?? UIImage()
        
        [originName, originType, containerView, planetImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.widthAnchor.constraint(equalToConstant: 64),
            
            planetImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            planetImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            originName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            originName.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 16),
            originName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            originType.leadingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: 16)
        ])
        let constraint1 = originType.topAnchor.constraint(lessThanOrEqualTo: originName.bottomAnchor, constant: 8)
        constraint1.priority = UILayoutPriority(1000)
        constraint1.isActive = true
        let constraint2 = originType.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        constraint2.priority = UILayoutPriority(999)
        constraint2.isActive = true
    }
}
