import UIKit

// MARK: - OriginCellModel
struct OriginCellModel: Hashable {
    let originName: String
    let originType: String
}

// MARK: - OriginCell
final class OriginCell: UICollectionViewCell, ReuseIdentifying, Identifiable {
    private let originName: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .title17
        label.numberOfLines = 0
        return label
    }()
    private let originType: UILabel = {
        let label = UILabel()
        label.textColor = .rmGreen
        label.font = .regular13
        return label
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.cornerRadius(10)
        view.backgroundColor = .rmBlack2
        return view
    }()
    private let planetImageView: UIImageView = {
        let view = UIImageView(image: .planet)
        return view
    }()
    var cellModel: OriginCellModel? {
        didSet {
            guard let cellModel else { return }
            originName.text = cellModel.originName
            originType.text = cellModel.originType
        }
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        fill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Intial UI setup
    private func fill() {
        cornerRadius(16)
        backgroundColor = .rmBlackSecondary
        
        [
            containerView, planetImageView,
            originName, originType
        ].forEach {
            addSubview($0)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(64)
        }
        
        planetImageView.snp.makeConstraints { make in
            make.center.equalTo(containerView.snp.center)
        }
        
        originName.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(containerView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        originType.snp.makeConstraints { make in
            make.leading.lessThanOrEqualTo(containerView.snp.trailing).offset(16)
            make.top.lessThanOrEqualTo(originName.snp.bottom).offset(8).priority(1000)
            make.bottom.lessThanOrEqualToSuperview().offset(-8).priority(999)
        }
    }
}
