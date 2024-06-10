import UIKit

// MARK: - CustomTabBarController
final class CustomTabBarController: UITabBarController {
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: .main)
        self.selectedIndex = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .rmBlackBG
        tabBar.tintColor = .rmBlackBG
        tabBar.barTintColor = .rmBlackBG
        tabBar.isTranslucent = false
        tabBar.overrideUserInterfaceStyle = .dark
    }
}
