import UIKit
import Lottie

// MARK: - CharactersListView
final class CharactersListView: UIView {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .title28
        label.text = .characters
        return label
    }()
    lazy var collectionView: UICollectionView = {
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
    lazy var activityIndicator: LottieAnimationView = {
        let view = LottieAnimationView(name: "loading")
        view.loopMode = .loop
        view.backgroundColor = .rmBlackSecondary.withAlphaComponent(0.75)
        view.cornerRadius(30)
        view.alpha = 0
        view.tag = 1
        return view
    }()
    lazy var retryView: RetryView = {
        let view = RetryView()
        view.tag = 1
        return view
    }()
    
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
    
    /// Showing indicator
    func showIndicator(_ isShowing: Bool) {
        let tag: Int = isShowing ? 0 : 1
        
        // return if state is already set
        guard tag != activityIndicator.tag else { return }
        
        activityIndicator.tag = tag
        let alpha: CGFloat = isShowing ? 1 : 0
        isShowing ? activityIndicator.play() : nil
        UIView.animate(withDuration: 0.2) {
            self.activityIndicator.alpha = alpha
        } completion: { [weak self] _ in
            isShowing ? nil : self?.activityIndicator.stop()
        }
    }
    
    // MARK: - Initial UI setup
    private func fill() {
        backgroundColor = .rmBlackBG
        [
            titleLabel, collectionView, activityIndicator,
            retryView
        ].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(24)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
        }
        
        retryView.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.center.equalToSuperview()
        }
    }
}
