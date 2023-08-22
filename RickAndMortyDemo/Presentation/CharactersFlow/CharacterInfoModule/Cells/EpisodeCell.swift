import UIKit

struct EpisodeCellModel: Hashable {
    let episode: EpisodeModel
}

final class EpisodeCell: UICollectionViewCell, ReuseIdentifying, Identifiable {
    private let episodeName = UILabel()
    private let airDate = UILabel()
    private let episode = UILabel()
    var cellModel: EpisodeModel? {
        didSet {
            guard let cellModel else { return }
            episodeName.text = cellModel.name
            airDate.text = cellModel.airDate
            episode.text = cellModel.episode
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
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        episodeName.textColor = .rmWhite
        episodeName.font = .title17
        episodeName.numberOfLines = 0
        episodeName.textAlignment = .left
        
        airDate.textColor = .rmGray2
        airDate.font = .regular12
        
        episode.textColor = .rmGreen
        episode.font = .regular13
        
        [episodeName, airDate, episode].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            episodeName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            episodeName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.25),
            episodeName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 15.68),
            
            airDate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            airDate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.68),
            
            episode.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            episode.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.25),
        ])
    }
}
