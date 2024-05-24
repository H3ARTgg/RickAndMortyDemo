import UIKit
import Combine

final class CharactersListViewController: UIViewController {
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    private let customView = CharactersListView()
    private let viewModel: CharactersListViewModelProtocol
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
    }
    
    // MARK: - Bindings
    private func binds() {
        viewModel.showLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                guard let self else { return }
                isVisible ? self.customView.activityIndicator.startAnimating() : self.customView.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.charactersPublisher
            .sink { _ in
        } receiveValue: { [weak self] _ in
            guard let self else { return }
            self.dataSource.reload(viewModel.getCharactersArray())
            self.customView.activityIndicator.stopAnimating()
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
            customView.activityIndicator.startAnimating()
            viewModel.requestCharacters()
        }
    }
}
