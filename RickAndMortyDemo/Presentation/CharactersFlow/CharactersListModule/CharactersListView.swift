import UIKit
import Lottie

// MARK: - CharactersListView
final class CharactersListView: UIView {
    private(set) var collectionView: UICollectionView = {
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
    private(set) var searchField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .rmBlackSecondary
        field.tintColor = .rmWhite
        field.font = .regular16
        field.cornerRadius(16)
        field.textColor = .rmWhite
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        field.attributedPlaceholder = NSAttributedString(
            string: .searchPlaceholder,
            attributes: [
                .foregroundColor: UIColor.rmWhite.withAlphaComponent(0.75),
                .font: UIFont.regular16
            ]
        )
        return field
    }()
    private(set) var retryView: RetryView = {
        let view = RetryView()
        view.tag = 1
        return view
    }()
    private(set) var cancelButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(), target: nil, action: nil)
        button.backgroundColor = .clear
        button.setTitle(.cancel, for: .normal)
        button.setTitleColor(.rmWhite, for: .normal)
        button.titleLabel?.font = .regular16
        button.alpha = 0
        return button
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
    private let cancelButtonWidth: CGFloat = 50
    
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
        loader.show(isShowing)
    }
    
    /// Show cancel button for text field
    func showCancel(_ isShowing: Bool) {
        let alpha: CGFloat = isShowing ? 1 : 0
        guard alpha != cancelButton.alpha else { return }
        let fieldTrailingOffset: CGFloat = isShowing ? -80 : -20
        let cancelWidth: CGFloat = isShowing ? cancelButtonWidth : 0
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.alpha = alpha
            
            self.cancelButton.snp.updateConstraints { make in
                make.width.equalTo(cancelWidth)
            }
            self.searchField.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(fieldTrailingOffset)
            }
            
            self.layoutIfNeeded()
        }
    }
    
    func showNothingFoundLabel(_ isShowing: Bool) {
        let alpha: CGFloat = isShowing ? 1 : 0
        guard alpha != nothingFoundLabel.alpha else { return }
        UIView.animate(withDuration: 0.3) {
            self.nothingFoundLabel.alpha = alpha
        }
    }
    
    // MARK: - Initial UI setup
    private func fill() {
        backgroundColor = .rmBlackBG
        [
            titleLabel, collectionView, loader,
            retryView, searchField, cancelButton,
            nothingFoundLabel
        ].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(24)
        }
        
        searchField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchField)
            make.height.equalTo(30)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
        }
        
        retryView.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.top.equalTo(searchField.snp.bottom).offset(20)
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
