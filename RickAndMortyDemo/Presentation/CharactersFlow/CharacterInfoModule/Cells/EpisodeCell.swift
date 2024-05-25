import UIKit

// MARK: - EpisodeCellModel
struct EpisodeCellModel: Hashable {
    let episode: EpisodeModel
}

// MARK: - EpisodeCell
final class EpisodeCell: UICollectionViewCell, ReuseIdentifying, Identifiable {
    private let episodeName: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .title17
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    private let airDate: UILabel = {
        let label = UILabel()
        label.textColor = .rmGray2
        label.font = .regular12
        return label
    }()
    private let episode: UILabel = {
        let label = UILabel()
        label.textColor = .rmGreen
        label.font = .regular13
        return label
    }()
    var cellModel: EpisodeModel? {
        didSet {
            guard let cellModel else { return }
            episodeName.text = cellModel.name
            airDate.text = cellModel.airDate
            episode.text = cellModel.episode
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

    // MARK: - Initial UI setip
    private func fill() {
        cornerRadius(16)
        backgroundColor = .rmBlackSecondary
        
        [episodeName, airDate, episode].forEach {
            addSubview($0)
        }
        
        episodeName.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        airDate.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        episode.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-14)
        }
    }
}
