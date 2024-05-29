import UIKit
import Combine

final class CharactersListViewController: UIViewController {
    // MARK: - Properties
    private let customView = CharactersListView()
    private let viewModel: CharactersListViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = CharactersListDataSource(customView.collectionView, viewModel)
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binds()
        viewModel.requestCharacters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Init
    required init(viewModel: CharactersListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initial UI setup
    private func setupUI() {
        // DataSource & Delegate
        customView.collectionView.dataSource = dataSource
        customView.collectionView.delegate = self
        
        // Target
        customView.retryView.retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
    }
    
    // MARK: - Bindings
    private func binds() {
        // for activity indicator
        viewModel.showLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isShowing in
                guard let self else { return }
                isShowing ? self.customView.indicator.show(true) : self.customView.indicator.show(false)
            }
            .store(in: &cancellables)
        
        // for reloading rows
        viewModel.charactersPublisher
            .sink { _ in
        } receiveValue: { [weak self] characters in
            guard let self else { return }
            // if error
            guard !characters.isEmpty else {
                self.customView.showRetry(true)
                return
            }
            self.customView.showRetry(false)
            self.dataSource.add(characters)
        }
        .store(in: &cancellables)
    }
}

// MARK: - Collection Delegate
extension CharactersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width / 2 - 8, height: collectionView.bounds.width / 1.6)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.moveToCharacterInfo(with: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.getCharactersCount() - 1 {
            viewModel.requestCharacters()
        }
    }
}

// MARK: - Actions
@objc
private extension CharactersListViewController {
    func didTapRetry() {
        viewModel.requestCharacters()
    }
}
