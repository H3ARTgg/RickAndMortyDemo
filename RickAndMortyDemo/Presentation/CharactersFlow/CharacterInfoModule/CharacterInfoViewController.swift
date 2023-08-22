import UIKit
import Combine

final class CharacterInfoViewController: UIViewController {
    private let scrollView = UIScrollView(frame: .zero)
    private let contentView = UIView(frame: .zero)
    private let characterImageView = UIImageView()
    private let characterNameLabel = UILabel()
    private let characterStatusLabel = UILabel()
    private let characterTableView = UITableView(frame: .zero, style: .insetGrouped)
    private let viewModel: CharacterInfoViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = CharacterInfoDataSource(self.characterTableView)
    
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
        let extraSpace = CGFloat((episodesCount * 90) - 90)
        configureScrollViewAndContentView(scrollView, contentView, with: extraSpace)
        configureImageView(characterImageView)
        configureNameLabel(characterNameLabel)
        configureStatusLabel(characterStatusLabel)
        configureTableView(characterTableView)
        addSubviews()
        addConstraints()
        characterTableView.backgroundColor = .clear
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

// MARK: TableView Delegate
extension CharacterInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CharacterInfoHeaderView.identifier) as? CharacterInfoHeaderView else { return nil }
        switch section {
        case 0:
            header.headerModel = Header.info
        case 1:
            header.headerModel = Header.origin
        case 2:
            header.headerModel = Header.episodes
        default:
            return nil
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 124
        case 1:
            return 80
        case 2:
            return 86
        default:
            return 42
        }
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
    
    func configureTableView(_ tableView: UITableView) {
        tableView.register(InfoCell.self)
        tableView.register(OriginCell.self)
        tableView.register(EpisodeCell.self)
        tableView.register(CharacterInfoHeaderView.self, forHeaderFooterViewReuseIdentifier: CharacterInfoHeaderView.identifier)
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.delegate = self
    }
    
    func addSubviews() {
        [characterImageView, characterNameLabel, characterStatusLabel, characterTableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [characterImageView, characterNameLabel, characterStatusLabel, characterTableView].forEach {
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
            
            
            characterTableView.topAnchor.constraint(
                equalTo: characterStatusLabel.bottomAnchor,
                constant: 24
            ),
            characterTableView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),
            characterTableView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),
            characterTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
