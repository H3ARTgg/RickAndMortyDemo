import UIKit

struct InfoCellModel: Hashable {
    let species: String
    let type: String
    let gender: String
}

final class InfoCell: UICollectionViewCell, ReuseIdentifying, Identifiable {
    private let speciesTitle = UILabel()
    private let typeTitle = UILabel()
    private let genderTitle = UILabel()
    private let speciesInfo = UILabel()
    private let typeInfo = UILabel()
    private let genderInfo = UILabel()
    var cellModel: InfoCellModel? {
        didSet {
            guard let cellModel else { return }
            speciesInfo.text = cellModel.species
            typeInfo.text = cellModel.type
            genderInfo.text = cellModel.gender
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
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .rmBlackSecondary
        
        speciesTitle.text = .species
        speciesTitle.textColor = .rmGray
        speciesTitle.font = .regular16
        
        typeTitle.text = .type
        typeTitle.textColor = .rmGray
        typeTitle.font = .regular16
        
        genderTitle.text = .gender
        genderTitle.textColor = .rmGray
        genderTitle.font = .regular16
        
        speciesInfo.textColor = .rmWhite
        speciesInfo.font = .regular16
        
        typeInfo.textColor = .rmWhite
        typeInfo.font = .regular16
        
        genderInfo.textColor = .rmWhite
        genderInfo.font = .regular16
        
        [speciesTitle, typeTitle, genderTitle, speciesInfo, typeInfo, genderInfo].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            speciesTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            speciesTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            typeTitle.topAnchor.constraint(equalTo: speciesTitle.bottomAnchor, constant: 16),
            typeTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            genderTitle.topAnchor.constraint(equalTo: typeTitle.bottomAnchor, constant: 16),
            genderTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            speciesInfo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            speciesInfo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            typeInfo.topAnchor.constraint(equalTo: speciesInfo.bottomAnchor, constant: 16),
            typeInfo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            genderInfo.topAnchor.constraint(equalTo: typeInfo.bottomAnchor, constant: 16),
            genderInfo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
