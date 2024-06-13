import UIKit
import Combine

final class FavoritesViewController: UIViewController {
    // MARK: - Properties
    private let customView = FavoritesView()
    private let viewModel: FavoritesViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = CharactersListDataSource(customView.collectionView)
    
    
    // MARK: - Lifecycle
    override func loadView() {
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binds()
        customView.showLoader(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.requestFavoriteCharacters()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Init
    init(viewModel: FavoritesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initial UI setup
    private func setupUI() {
        // TabBar Settings
        let tabBarItem = UITabBarItem(
            title: "Favorites",
            image: .heart.resize(to: CGSize(width: 25, height: 25))?.withTintColor(.rmGray2, renderingMode: .alwaysOriginal),
            selectedImage:  .heart.resize(to: CGSize(width: 25, height: 25))?.withTintColor(.rmWhite, renderingMode: .alwaysOriginal)
        )
        tabBarItem.setTitleTextAttributes([
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.rmGray2
        ], for: .normal)
        tabBarItem.setTitleTextAttributes([
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.rmWhite
        ], for: .selected)
        self.tabBarItem = tabBarItem
        
        // DataSource & Delegate
        customView.collectionView.dataSource = dataSource
        customView.collectionView.delegate = self
        
        // Target
        customView.retryView.retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
    }
    
    // MARK: - Bindings
    private func binds() {
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.customView.showRetry(true)
                self.customView.showLoader(false)
            }
            .store(in: &cancellables)
        
        viewModel.charactersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                guard let self else { return }
                self.customView.noFavoritesLabel.isHidden = !characters.isEmpty
                
                self.customView.showRetry(false)
                self.customView.showLoader(false)
                
                self.dataSource.reload(characters)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Collection Delegate
extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width / 2 - 8, height: collectionView.bounds.width / 1.6)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.routeToCharacterInfo(with: indexPath)
    }
}

// MARK: - Actions
@objc
private extension FavoritesViewController {
    func didTapRetry() {
        customView.showLoader(true)
        viewModel.requestFavoriteCharacters()
    }
}
