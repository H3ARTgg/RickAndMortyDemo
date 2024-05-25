import UIKit
import Lottie

// MARK: - CharacterInfoView
final class CharacterInfoView: UIView {
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.bounces = true
        view.backgroundColor = .clear
        return view
    }()
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    lazy var characterImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.cornerRadius(10)
        return view
    }()
    lazy var characterNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .title22
        label.numberOfLines = 0
        return label
    }()
    lazy var characterStatusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .regular16
        return label
    }()
    lazy var characterCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.register(InfoCell.self)
        collection.register(OriginCell.self)
        collection.register(EpisodeCell.self)
        collection.register(CharacterInfoSupView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CharacterInfoSupView.identifier)
        collection.isScrollEnabled = false
        collection.allowsSelection = false
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    lazy var activityIndicator: LottieAnimationView = {
        let view = LottieAnimationView(name: "loading")
        view.loopMode = .loop
        view.backgroundColor = .rmBlackSecondary.withAlphaComponent(0.75)
        view.cornerRadius(30)
        view.alpha = 0
        return view
    }()
    lazy var retryView: RetryView = {
        let view = RetryView()
        view.titleLabel.text = .failedCharacterInfo
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
    
    /// Updating CharacterInfoView with data
    func setCharacterInfo(model: CharacterModel, imageData: Data) {
        characterImageView.image = UIImage(data: imageData)
        characterNameLabel.text = model.name
        setCharacterStatus(model.status)
        characterCollectionView.snp.updateConstraints { make in
            make.height.equalTo(characterCollectionView.contentSize.height)
        }
    }
    
    /// Setting character status properties
    private func setCharacterStatus(_ status: String) {
        switch status {
        case "Alive":
            characterStatusLabel.textColor = .rmGreen
            characterStatusLabel.text = .alive
        case "Dead":
            characterStatusLabel.textColor = .rmRed
            characterStatusLabel.text = .dead
        case _:
            characterStatusLabel.textColor = .rmYellow
            characterStatusLabel.text = .unknown
        }
    }
    
    // MARK: Initial UI setup
    private func fill() {
        backgroundColor = .rmBlackBG
        
        [scrollView, activityIndicator, retryView].forEach {
            addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.center.equalToSuperview()
        }
        
        retryView.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.bottom.centerX.width.equalToSuperview()
            make.height.equalTo(scrollView).priority(250)
        }
        
        [
            characterImageView, characterNameLabel, characterStatusLabel,
            characterCollectionView
        ].forEach {
            contentView.addSubview($0)
        }
        
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(150)
            make.centerX.equalToSuperview()
        }
        
        characterNameLabel.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        characterStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(characterNameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        characterCollectionView.snp.makeConstraints { make in
            make.top.equalTo(characterStatusLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(350)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
}
