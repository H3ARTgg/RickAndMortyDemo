import UIKit

final class RetryView: UIView {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .rmWhite
        label.font = .title17
        label.textAlignment = .center
        label.text = "Failed to get characters"
        return label
    }()
    lazy var retryButton: UIButton = {
        let image = UIImage(systemName: "repeat")?.withTintColor(.rmBlack2, renderingMode: .alwaysOriginal) ?? UIImage()
        let button = UIButton.systemButton(with: image, target: nil, action: nil)
        button.backgroundColor = .rmWhite
        button.cornerRadius(12)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fill() {
        backgroundColor = .rmRed
        cornerRadius(12, maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        
        [titleLabel, retryButton].forEach {
            addSubview($0)
        }
        
        retryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.height.width.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(retryButton.snp.leading).offset(-20)
        }
    }
}
