import UIKit

final class CharactersListCell: UICollectionViewCell, ReuseIdentifying, Identifiable {
    private let containerView = UIView()
    private let characterLabel = UILabel()
    private let characterImage = UIImageView()
    var cellModel: CharactersListCellModel? {
        didSet {
            guard let cellModel else { return }
            self.characterLabel.text = cellModel.name
            self.characterImage.image = UIImage(data: cellModel.imageData)
            // scroll indicator fix (appearing on top of content)
            contentView.subviews.forEach {
                $0.removeFromSuperview()
            }
            configureContainerView(containerView)
            configureCharacterLabel(characterLabel)
            configureCharacterImage(characterImage)
            addSubviews()
            addConstraints(rowNumber: cellModel.rowNumber)
        }
    }
}

// MARK: - UI
private extension CharactersListCell {
    func configureContainerView(_ view: UIView) {
        view.backgroundColor = .rmBlackSecondary
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    }
    
    func configureCharacterLabel(_ label: UILabel) {
        label.textColor = .rmWhite
        label.font = .title17
        label.numberOfLines = 0
        label.textAlignment = .center
    }
    
    func configureCharacterImage(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
    }
    
    func addSubviews() {
        [containerView, characterLabel, characterImage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0 != containerView ? containerView.addSubview($0) : contentView.addSubview($0)
        }
    }
    
    func addConstraints(rowNumber: Int) {
        var leadingConstant: CGFloat = 0
        var trailingConstant: CGFloat = 0
        
        if rowNumber % 2 == 0 {
            leadingConstant = 20; trailingConstant = 0
        } else {
            leadingConstant = 0; trailingConstant = 27
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leadingConstant),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -trailingConstant),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            characterImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            characterImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            characterImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            characterImage.heightAnchor.constraint(equalToConstant: 140),
            
            characterLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            characterLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])
        let constraint1 = characterLabel.topAnchor.constraint(lessThanOrEqualTo: characterImage.bottomAnchor, constant: 16)
        constraint1.priority = UILayoutPriority(1000)
        constraint1.isActive = true
        let constraint2 = characterLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
        constraint2.priority = UILayoutPriority(999)
        constraint2.isActive = true
    }
}
