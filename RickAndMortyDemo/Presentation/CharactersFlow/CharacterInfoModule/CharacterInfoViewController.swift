import UIKit
import Combine

final class CharacterInfoViewController: UIViewController {
    private let scrollView = UIScrollView(frame: .zero)
    private let contentView = UIView(frame: .zero)
    private let characterImageView = UIImageView()
    private let characterNameLabel = UILabel()
    private let characterStatusLabel = UILabel()
    private let characterCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let viewModel: CharacterInfoViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = CharacterInfoDataSource(self.characterCollectionView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        binds()
        viewModel.requestCharacterOriginAndEpisodes()
    }
    
    init(viewModel: CharacterInfoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func moveBackToRootViewController() {
        viewModel.moveBackToRootViewController()
    }
    
    private func binds() {
        Publishers.Zip(viewModel.characterOriginPublisher, viewModel.episodesPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] (origin, episodes) in
                guard let self else { return }
                self.configureWith(episodesCount: episodes.count)
                let data = self.viewModel.makeDataSourceData(
                    characterModel: self.viewModel.characterModel,
                    origin: origin,
                    episodes: episodes
                )
                self.dataSource.reload(data)
                self.characterImageView.image = UIImage(data: viewModel.imageData)
                self.characterNameLabel.text = viewModel.characterModel.name
                self.checkForStatus(viewModel.characterModel.status)
            })
            .store(in: &cancellables)
    }
    
    private func configureViewController() {
        view.backgroundColor = .rmBlackBG
        self.navigationItem.hidesBackButton = true
        
        let button = UIBarButtonItem(image: UIImage(named: "chevron_left"), style: .done, target: self, action: #selector(moveBackToRootViewController))
        button.tintColor = .rmWhite
        
        self.navigationItem.setLeftBarButton(button, animated: true)
    }
    
    private func configureWith(episodesCount: Int) {
        let extraSpace = CGFloat((episodesCount * 102) - 102)
        configureScrollViewAndContentView(scrollView, contentView, with: extraSpace)
        configureImageView(characterImageView)
        configureNameLabel(characterNameLabel)
        configureStatusLabel(characterStatusLabel)
        configureTableView(characterCollectionView)
        addSubviews()
        addConstraints()
        characterCollectionView.backgroundColor = .clear
    }
    
    private func checkForStatus(_ status: String) {
        characterStatusLabel.text = status
        if status == "Alive" {
            characterStatusLabel.textColor = .rmGreen
        } else if status == "Dead" {
            characterStatusLabel.textColor = .rmRed
        } else if status == "unknown" {
            characterStatusLabel.textColor = .rmYellow
        }
    }
}

// MARK: CollectionView Delegate
extension CharacterInfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.frame.width, height: 124)
        case 1:
            return CGSize(width: collectionView.frame.width, height: 80)
        case 2:
            return CGSize(width: collectionView.frame.width, height: 86)
        default:
            return CGSize(width: collectionView.frame.width, height: 86)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 2 {
            return 16
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width:collectionView.bounds.width , height: 62)
    }
}

// MARK: - UI elements
private extension CharacterInfoViewController {
    func configureScrollViewAndContentView(_ scrollView: UIScrollView, _ contentView: UIView, with extraSpace: CGFloat) {
        scrollView.maximumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.isScrollEnabled = true
        scrollView.indicatorStyle = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + extraSpace)
        let topOffset = CGPoint(x: 0, y: 0)
        scrollView.setContentOffset(topOffset, animated: false)
        
        view.addSubview(scrollView)
        
        contentView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height + extraSpace)
        
        contentView.backgroundColor = .rmBlackBG
        scrollView.addSubview(contentView)
    }
    
    func configureImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
    }
    
    func configureNameLabel(_ label: UILabel) {
        label.textColor = .rmWhite
        label.font = .title22
        label.numberOfLines = 0
    }
    
    func configureStatusLabel(_ label: UILabel) {
        label.textColor = .rmWhite
        label.font = .regular16
    }
    
    func configureTableView(_ colView: UICollectionView) {
        colView.register(InfoCell.self)
        colView.register(OriginCell.self)
        colView.register(EpisodeCell.self)
        colView.register(CharacterInfoSupView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CharacterInfoSupView.identifier)
        colView.isScrollEnabled = false
        colView.allowsSelection = false
        colView.delegate = self
        colView.backgroundColor = .clear
    }
    
    func addSubviews() {
        [characterImageView, characterNameLabel, characterStatusLabel, characterCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [characterImageView, characterNameLabel, characterStatusLabel, characterCollectionView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            characterImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 148),
            characterImageView.heightAnchor.constraint(equalToConstant: 148),
            
            characterNameLabel.topAnchor.constraint(
                equalTo: characterImageView.bottomAnchor,
                constant: 24
            ),
            characterNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            
            characterStatusLabel.topAnchor.constraint(
                equalTo: characterNameLabel.bottomAnchor,
                constant: 8
            ),
            characterStatusLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            
            characterCollectionView.topAnchor.constraint(
                equalTo: characterStatusLabel.bottomAnchor,
                constant: 24
            ),
            characterCollectionView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),
            characterCollectionView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),
            characterCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
