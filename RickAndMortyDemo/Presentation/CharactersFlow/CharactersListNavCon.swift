import UIKit

final class CharactersListNavCon: UINavigationController {
    init() {
        super.init(nibName: nil, bundle: .main)
        self.navigationBar.barStyle = .black
        self.navigationBar.tintColor = .rmBlackBG
        self.navigationBar.barTintColor = .rmBlackBG
        self.navigationBar.backgroundColor = .rmBlackBG
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
