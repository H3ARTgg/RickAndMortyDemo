import UIKit
import Combine

final class CharactersListViewController: UIViewController {
    // MARK: - Properties
    private let customView = CharactersListView()
    private let viewModel: CharactersListViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = CharactersListDataSource(customView.collectionView)
    private var isScrolledToTop: Bool = true
    
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
        /// for updating like state (if disliked in favorites screen)
        customView.collectionView.reloadData()
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
        customView.searchView.delegate = self
        customView.filterView.delegate = self
        
        // Targets
        customView.retryView.retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        customView.filterButton.addTarget(self, action: #selector(didTapFilter), for: .touchUpInside)
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
                isNext ? nil : customView.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            })
            .store(in: &cancellables)
        
        // for search
        viewModel.characterSearchPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (cellModels, isNext) in
                guard let self else { return }
                
                cellModels.isEmpty && !isNext ? customView.showNothingFoundLabel(true) : customView.showNothingFoundLabel(false)
                
                self.customView.showLoader(false)
                
                if !customView.collectionView.visibleCells.isEmpty {
                    isNext ? nil : customView.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
                isNext ? self.dataSource.add(cellModels) : self.dataSource.reload(cellModels)
            })
            .store(in: &cancellables)
    }
}

// MARK: - FilterView Delegate
extension CharactersListViewController: FilterViewDelegate {
    func didReceiveFilters(_ filters: [CharacterSearchType]) {
        viewModel.setFilters(filters)
        viewModel.search(customView.searchView.searchField.text, isNext: false)
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
        isScrolledToTop = indexPath.row < 3
        
        if indexPath.row == viewModel.getCharactersCount() - 1 {
            viewModel.requestCharacters(isNext: true)
            customView.showLoader(true)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if isScrolledToTop || customView.collectionView.visibleCells.count < 6 {
            customView.showSearch(true)
            return
        }
        
        if velocity.y.sign == .minus {
            if velocity.y > -2 {
                return
            }
        }
        
        guard velocity.y != 0 else { return }
        customView.showSearch(velocity.y < 0)
    }
}

// MARK: - SearchViewDelegate
extension CharactersListViewController: SearchViewDelegate {
    func didTapCancel() {
        viewModel.setFilters([])
        customView.filterView.resetAll()
        customView.showNothingFoundLabel(false)
        viewModel.requestCharacters(isNext: false)
    }
    
    func search(with text: String) {
        if !text.isEmpty {
            customView.showLoader(true)
            viewModel.search(text, isNext: false)
        } else {
            customView.showNothingFoundLabel(false)
            viewModel.requestCharacters(isNext: false)
        }
    }
}

// MARK: - Action
@objc
private extension CharactersListViewController {
    func didTapRetry() {
        customView.showLoader(true)
        viewModel.requestCharacters(isNext: true)
    }
    
    func didTapFilter() {
        customView.filterView.isShowing.toggle()
        customView.showFilter(customView.filterView.isShowing)
    }
}
