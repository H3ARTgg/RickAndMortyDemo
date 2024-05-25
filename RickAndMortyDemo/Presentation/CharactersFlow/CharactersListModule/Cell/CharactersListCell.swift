import UIKit

// MARK: - CharactersListCell
final class CharactersListCell: UICollectionViewCell, ReuseIdentifying, Identifiable {
    lazy var characterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .title17
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private let characterImage: UIImageView = {
        let view = UIImageView()
        view.cornerRadius(10)
        return view
    }()
    var cellModel: CharactersListCellModel? {
        didSet {
            guard let cellModel else { return }
            self.characterLabel.text = cellModel.name
            self.characterImage.image = UIImage(data: cellModel.imageData)
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
    
    // MARK: - Initial UI setup
    private func fill() {
        backgroundColor = .rmBlackSecondary
        cornerRadius(16)
        
        [characterImage, characterLabel].forEach {
            addSubview($0)
        }
        
        let imageSize = bounds.width - 16
        characterImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.height.equalTo(imageSize)
        }
        
        characterLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.lessThanOrEqualTo(characterImage.snp.bottom).offset(16).priority(1000)
            make.bottom.lessThanOrEqualToSuperview().offset(-8).priority(999)
        }
    }
}
