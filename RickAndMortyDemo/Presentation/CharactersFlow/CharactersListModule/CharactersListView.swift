import UIKit
import Lottie

// MARK: - CharactersListView
final class CharactersListView: UIView {
    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.backgroundColor = .clear
        collection.register(CharactersListCell.self)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        
        return collection
    }()
    let retryView: RetryView = {
        let view = RetryView()
        view.tag = 1
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .title28
        label.text = .characters
        return label
    }()
    private let nothingFoundLabel: UILabel = {
        let label = UILabel()
        label.font = .title17
        label.textColor = .rmWhite
        label.textAlignment = .center
        label.text = .nothingFound
        label.alpha = 0
        return label
    }()
    private let loader: CustomLoader = CustomLoader(frame: .zero)
    let searchView = SearchView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        fill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Showing RetryView if connection fails
    func showRetry(_ isShowing: Bool) {
        let tag: Int = isShowing ? 0 : 1
        
        // return if state is already set
        guard tag != retryView.tag else { return }
        
        let height: CGFloat = isShowing ? 40 : 0
        
        retryView.tag = tag
        UIView.animate(withDuration: 0.5) {
            self.retryView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            self.layoutIfNeeded()
        }
    }
    
    /// Show loader
    func showLoader(_ isShowing: Bool) {
        let isUserInteractionEnabled = !isShowing
        self.searchView.cancelButton.isUserInteractionEnabled = isUserInteractionEnabled
        self.collectionView.isUserInteractionEnabled = isUserInteractionEnabled
        
        loader.show(isShowing)
    }
    
    func showNothingFoundLabel(_ isShowing: Bool) {
        let alpha: CGFloat = isShowing ? 1 : 0
        guard alpha != nothingFoundLabel.alpha else { return }
        UIView.animate(withDuration: 0.3) {
            self.nothingFoundLabel.alpha = alpha
        }
    }
    
    func showSearch(_ isShowing: Bool) {
        let height = isShowing ? 40 : 0
        let topOffset = isShowing ? 20 : 0
        
        guard searchView.accessibilityIdentifier != "animating" else { return }
        searchView.accessibilityIdentifier = "animating"
        
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction]) {
            self.searchView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            self.collectionView.snp.updateConstraints { make in
                make.top.equalTo(self.searchView.snp.bottom).offset(topOffset)
            }
            self.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.searchView.accessibilityIdentifier = "not_animating"
        }
    }
    
    // MARK: - Initial UI setup
    private func fill() {
        backgroundColor = .rmBlackBG
        [
            titleLabel, collectionView, loader,
            retryView, searchView,
            nothingFoundLabel
        ].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(24)
        }
        
        searchView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
        
        retryView.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.top.equalTo(searchView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        loader.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.center.equalToSuperview()
        }
        
        nothingFoundLabel.snp.makeConstraints { make in
            make.center.equalTo(collectionView.snp.center)
        }
    }
}
