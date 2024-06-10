import UIKit
import Combine

final class CharactersListViewController: UIViewController {
    // MARK: - Properties
    private let customView = CharactersListView()
    private let viewModel: CharactersListViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = CharactersListDataSource(customView.collectionView)
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binds()
        customView.showLoader(true)
        viewModel.requestCharacters(isNext: true)
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
        // TabBar Settings
        let tabBarItem = UITabBarItem(
            title: .characters,
            image: .character.resize(to: CGSize(width: 25, height: 25))?.withTintColor(.rmGray2, renderingMode: .alwaysOriginal),
            selectedImage: .character.resize(to: CGSize(width: 25, height: 25))?.withTintColor(.rmWhite, renderingMode: .alwaysOriginal)
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
        customView.searchField.delegate = self
        
        // Targets
        customView.retryView.retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        customView.searchField.addTarget(self, action: #selector(didInteractWithSearch), for: .editingChanged)
        customView.cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
    }
    
    // MARK: - Bindings
    private func binds() {
        // for errors
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.customView.showRetry(true)
                self.customView.showLoader(false)
            }
            .store(in: &cancellables)
        
        // for data
        viewModel.charactersPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (cellModels, isNext) in
                guard let self else { return }
                self.customView.showRetry(false)
                self.customView.showLoader(false)
                
                isNext ? self.dataSource.add(cellModels) : self.dataSource.reload(cellModels)
            })
            .store(in: &cancellables)
        
        // for search
        viewModel.characterSearchPublisher
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .sink(receiveValue: { [weak self] models in
                guard let self else { return }
                
                models.isEmpty ? customView.showNothingFoundLabel(true) : customView.showNothingFoundLabel(false)
                
                self.customView.showLoader(false)
                self.dataSource.reload(models)
            })
            .store(in: &cancellables)
    }
}

// MARK: - Collection Delegate
extension CharactersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width / 2 - 8, height: collectionView.bounds.width / 1.6)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.routeToCharacterInfo(with: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.getCharactersCount() - 1 {
            viewModel.requestCharacters(isNext: true)
            customView.showLoader(true)
        }
    }
}

// MARK: - TextField Delegate
extension CharactersListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

// MARK: - Actions
@objc
private extension CharactersListViewController {
    func didTapRetry() {
        customView.showLoader(true)
        viewModel.requestCharacters(isNext: true)
    }
    
    func didTapCancel() {
        customView.endEditing(true)
        customView.showCancel(false)
        customView.searchField.text = ""
        customView.showNothingFoundLabel(false)
        viewModel.requestCharacters(isNext: false)
    }
    
    func didInteractWithSearch() {
        if let text = customView.searchField.text, !text.isEmpty {
            customView.showCancel(true)
            customView.showLoader(true)
            viewModel.search(text)
        } else {
            customView.showCancel(false)
            customView.showNothingFoundLabel(false)
            viewModel.requestCharacters(isNext: false)
        }
    }
}
