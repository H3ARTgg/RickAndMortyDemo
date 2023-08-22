import UIKit
import Combine

final class CharactersListViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    private let titleLabel = UILabel()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let viewModel: CharactersListViewModelProtocol
    private lazy var dataSource = CharactersListDataSource(collectionView, viewModel, self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = dataSource
        configures()
        addSubviews()
        addConstraints()
        binds()
        viewModel.requestCharacters()
    }
    
    required init(viewModel: CharactersListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configures() {
        view.backgroundColor = .rmBlackBG
        configureTitleLabel(titleLabel)
        configureCollectionView(collectionView)
    }
    
    private func binds() {
        viewModel.showLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                isVisible ? self?.showActivityIndicator() : self?.removeActivityIndicator()
            }
            .store(in: &cancellables)
        
        Publishers.Zip(viewModel.charactersPublisher, viewModel.imagesPublisher)
            .receive(on: DispatchQueue.main)
            .sink { _ in
        } receiveValue: { [weak self] _ in
            guard let self else { return }
            let cellModels = self.viewModel.recieveCellModels()
            self.dataSource.reload(cellModels)
            removeActivityIndicator()
        }
        .store(in: &cancellables)
    }
}

// MARK: - CollectionView Delegate
extension CharactersListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width / 2 - 8, height: 202)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.moveToCharacterInfo(with: indexPath)
    }
}

// MARK: - DiffableDataSource Delegate
extension CharactersListViewController: DiffableDataSourceDelegate {
    func showActivityIndicator() {
        let window = UIApplication.keyWindow
        window?.isUserInteractionEnabled = false
        configureActivityIndicator(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func removeActivityIndicator() {
        let window = UIApplication.keyWindow
        window?.isUserInteractionEnabled = true
        
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}

// MARK: - UI elements
private extension CharactersListViewController {
    func configureTitleLabel(_ title: UILabel) {
        title.textColor = .rmWhite
        title.font = .title28
        title.text = .characters
    }
    
    func configureCollectionView(_ colView: UICollectionView) {
        colView.backgroundColor = .clear
        colView.delegate = self
        colView.register(CharactersListCell.self)
        colView.indicatorStyle = .white
    }
    
    func configureActivityIndicator(_ indicator: UIActivityIndicatorView) {
        indicator.color = .rmWhite
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func addSubviews() {
        [titleLabel, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 18 + 48),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 31),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
