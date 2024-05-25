import UIKit

// MARK: - InfoCellModel
struct InfoCellModel: Hashable {
    let species: String
    let type: String
    let gender: String
}

// MARK: - InfoCell
final class InfoCell: UICollectionViewCell, ReuseIdentifying, Identifiable {
    private let speciesTitle: UILabel = {
        let label = UILabel()
        label.text = .species
        label.textColor = .rmGray
        label.font = .regular16
        return label
    }()
    private let typeTitle: UILabel = {
        let label = UILabel()
        label.text = .type
        label.textColor = .rmGray
        label.font = .regular16
        return label
    }()
    private let genderTitle: UILabel = {
        let label = UILabel()
        label.text = .gender
        label.textColor = .rmGray
        label.font = .regular16
        return label
    }()
    private let speciesInfo: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .regular16
        return label
    }()
    private let typeInfo: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .regular16
        return label
    }()
    private let genderInfo: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .regular16
        return label
    }()
    var cellModel: InfoCellModel? {
        didSet {
            guard let cellModel else { return }
            speciesInfo.text = cellModel.species
            typeInfo.text = cellModel.type
            genderInfo.text = cellModel.gender
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
        cornerRadius(16)
        backgroundColor = .rmBlackSecondary
        
        [
            speciesTitle, typeTitle, genderTitle,
            speciesInfo, typeInfo, genderInfo
        ].forEach {
            addSubview($0)
        }
        
        speciesTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        typeTitle.snp.makeConstraints { make in
            make.top.equalTo(speciesTitle.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        genderTitle.snp.makeConstraints { make in
            make.top.equalTo(typeTitle.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        speciesInfo.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        typeInfo.snp.makeConstraints { make in
            make.top.equalTo(speciesInfo.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        genderInfo.snp.makeConstraints { make in
            make.top.equalTo(typeInfo.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
}
