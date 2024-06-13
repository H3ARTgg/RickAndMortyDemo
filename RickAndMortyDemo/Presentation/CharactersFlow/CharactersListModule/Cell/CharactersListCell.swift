import UIKit

// MARK: - CharactersListCell
final class CharactersListCell: UICollectionViewCell, ReuseIdentifying, Identifiable {
    private let characterLabel: UILabel = {
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
    private(set) lazy var likeButton: UIButton = {
        let button = UIButton.systemButton(with: .heart, target: self, action: #selector(didTapLike))
        button.backgroundColor = .clear
        button.tintColor = .rmGray2
        return button
    }()
    weak var cellModel: CharactersListCellModel? {
        didSet {
            guard let cellModel else { return }
            characterLabel.text = cellModel.name
            characterImage.image = UIImage(data: cellModel.imageData)
            likeButton.tintColor = cellModel.isLiked ? likedColor : notLikedColor
            likeButton.alpha = cellModel.isLiked ? likedAlpha : notLikedAlpha
        }
    }
    
    private let likedColor = UIColor.rmRed
    private let likedAlpha: CGFloat = 1
    
    private let notLikedColor = UIColor.rmBlackSecondary
    private let notLikedAlpha: CGFloat = 0.75
    
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
        
        [characterImage, characterLabel, likeButton].forEach {
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
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(characterImage.snp.top).offset(5)
            make.trailing.equalTo(characterImage.snp.trailing).offset(-5)
            make.width.height.equalTo(30)
        }
    }
}

// MARK: - Actions
@objc
private extension CharactersListCell {
    func didTapLike(_ sender: UIButton) {
        let isLiked = sender.tintColor == .rmRed ? true : false
        let newColor: UIColor = isLiked ? notLikedColor : likedColor
        
        UIView.animate(withDuration: 0.3, animations: {
            sender.tintColor = newColor
            sender.transform = !isLiked ? CGAffineTransform(scaleX: 1.2, y: 1.2) : CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = !isLiked ? self.likedAlpha : self.notLikedAlpha
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                sender.transform = CGAffineTransform.identity
            }
        }
        cellModel?.isLiked = !isLiked
    }
}
