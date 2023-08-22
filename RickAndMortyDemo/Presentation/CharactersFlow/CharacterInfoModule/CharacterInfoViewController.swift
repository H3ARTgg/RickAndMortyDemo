import UIKit
import Combine

final class CharacterInfoViewController: UIViewController {
    private let scrollView = UIScrollView(frame: .zero)
    private let contentView = UIView(frame: .zero)
    private let imageView = UIImageView()
    private let viewModel: CharacterInfoViewModelProtocol
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        addSubviews()
        addConstraints()
    }
    
    init(viewModel: CharacterInfoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func moveBackToRootViewController() {
        viewModel.moveBackToRootViewController()
    }
    
    private func configureViewController() {
        view.backgroundColor = .rmBlackBG
        self.navigationItem.hidesBackButton = true
        
        let button = UIBarButtonItem(image: UIImage(named: "chevron_left"), style: .done, target: self, action: #selector(moveBackToRootViewController))
        button.tintColor = .rmWhite
        
        self.navigationItem.setLeftBarButton(button, animated: true)
    }
}

// MARK: - UI elements
private extension CharacterInfoViewController {
    func configureScrollView(_ scrollView: UIScrollView) {
        scrollView.maximumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.isScrollEnabled = true
        scrollView.indicatorStyle = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func configureContentView(_ contentView: UIView) {
        
    }
    
    func configureImageView(_ imageView: UIImageView) {
        
    }
    
    func addSubviews() {
        [scrollView, contentView, imageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        
        [imageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            
        ])
    }
}
