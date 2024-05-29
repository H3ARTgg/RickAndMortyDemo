import UIKit
import Combine

final class CharacterInfoViewController: UIViewController {
    // MARK: - Properties
    private let customView = CharacterInfoView()
    private let viewModel: CharacterInfoViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = CharacterInfoDataSource(customView.characterCollectionView)
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binds()
        customView.indicator.show(true)
        viewModel.requestCharacterOriginAndEpisodes()
    }
    
    // MARK: - Init
    init(viewModel: CharacterInfoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initial UI setup
    private func setupUI() {
        // Back Button
        let button = UIBarButtonItem(image: UIImage(named: "chevron_left"), style: .done, target: self, action: #selector(didTapBack))
        button.tintColor = .rmWhite
        navigationItem.hidesBackButton = true
        navigationItem.setLeftBarButton(button, animated: true)
        
        // DataSource & Delegate
        customView.characterCollectionView.dataSource = dataSource
        customView.characterCollectionView.delegate = self
        
        // Target
        customView.retryView.retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        
        // Swipe Gesture
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didTapBack))
        swipeGesture.direction = .right
        customView.addGestureRecognizer(swipeGesture)
    }
    
    // MARK: - Bindings
    private func binds() {
        Publishers.Zip(viewModel.characterOriginPublisher, viewModel.episodesPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] (origin, episodes) in
                guard let self else { return }
                // if error
                guard origin.name != "Error" else {
                    self.customView.showRetry(true)
                    self.customView.indicator.show(false)
                    return
                }
                guard !episodes.isEmpty else {
                    self.customView.showRetry(true)
                    self.customView.indicator.show(false)
                    return
                }
                self.customView.showRetry(false)
                
                let model = viewModel.getCharactersInfo()
                let data = self.viewModel.makeDataSourceData(
                    characterModel: model.model,
                    origin: origin,
                    episodes: episodes
                )
                self.dataSource.reload(data)
                self.customView.setCharacterInfo(model: model.model, imageData: model.imageData)
                self.customView.indicator.show(false)
            })
            .store(in: &cancellables)
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
        CGSize(width:collectionView.bounds.width, height: 62)
    }
}

// MARK: - Actions
@objc
private extension CharacterInfoViewController {
    func didTapBack() {
        viewModel.moveBackToRootViewController()
    }
    
    func didTapRetry() {
        viewModel.requestCharacterOriginAndEpisodes()
        customView.indicator.show(true)
    }
}
