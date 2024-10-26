import UIKit

// MARK: - SearchViewDelegate
protocol SearchViewDelegate: AnyObject {
    func didTapCancel()
    func search(with text: String)
}

// MARK: - SearchView
final class SearchView: UIView {
    let containerView: UIView = {
        let view = UIView()
        view.cornerRadius(16)
        view.backgroundColor = .rmBlackSecondary
        return view
    }()
    let imageView: UIImageView = {
        let view = UIImageView(image: .search)
        view.contentMode = .scaleAspectFill
        return view
    }()
    let searchField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .clear
        field.tintColor = .rmWhite
        field.font = .regular16
        field.textColor = .rmWhite
        field.attributedPlaceholder = NSAttributedString(
            string: .searchPlaceholder,
            attributes: [
                .foregroundColor: UIColor.rmWhite.withAlphaComponent(0.75),
                .font: UIFont.regular16
            ]
        )
        return field
    }()
    let cancelButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(), target: nil, action: nil)
        button.backgroundColor = .clear
        button.setTitle(.cancel, for: .normal)
        button.setTitleColor(.rmWhite, for: .normal)
        button.titleLabel?.font = .regular16
        button.alpha = 0
        return button
    }()
    weak var delegate: SearchViewDelegate?
    private let cancelButtonWidth: CGFloat = 50
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        
        searchField.delegate = self
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        searchField.addTarget(self, action: #selector(didInteractWithSearch), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    /// Show cancel button for text field
    func showCancel(_ isShowing: Bool) {
        let alpha: CGFloat = isShowing ? 1 : 0
        guard alpha != cancelButton.alpha else { return }
        let cancelWidth: CGFloat = isShowing ? cancelButtonWidth : 0
        let trailingOffset = isShowing ? -62 : 0
        UIView.animate(withDuration: 0.3) {
            self.cancelButton.alpha = alpha
            self.containerView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(trailingOffset)
            }
            self.cancelButton.snp.updateConstraints { make in
                make.width.equalTo(cancelWidth)
            }
            
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc
    private func didTapCancel() {
        endEditing(true)
        showCancel(false)
        searchField.text = ""
        delegate?.didTapCancel()
    }
    
    @objc
    private func didInteractWithSearch() {
        if let text = searchField.text, !text.isEmpty {
            showCancel(true)
            delegate?.search(with: text)
        } else {
            showCancel(false)
            delegate?.search(with: "")
        }
    }
}

// MARK: - TextField Delegate
extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}

// MARK: - Layout
extension SearchView {
    private func layout() {
        backgroundColor = .clear
        addSubview(containerView)
        addSubview(cancelButton)
        
        [
            imageView,
            searchField,
        ].forEach { containerView.addSubview($0) }
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.top.trailing.equalToSuperview()
            make.width.equalTo(0)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(0)
        }
        
        imageView.snp.makeConstraints { make in
            let size = 18
            let leadingOffset = 12
            
            make.height.width.equalTo(size)
            make.leading.equalToSuperview().offset(leadingOffset)
            make.centerY.equalToSuperview()
        }
        
        searchField.snp.makeConstraints { make in
            let offset = 12
            
            make.leading.equalTo(imageView.snp.trailing).offset(offset)
            make.trailing.equalToSuperview().offset(-offset)
            make.bottom.top.equalToSuperview()
        }
    }
}
