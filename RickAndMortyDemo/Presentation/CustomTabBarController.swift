import UIKit

// MARK: - CustomTabBarController
final class CustomTabBarController: UITabBarController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .rmBlackBG
        tabBar.tintColor = .rmBlackBG
        tabBar.barTintColor = .rmBlackBG
        tabBar.isTranslucent = false
        tabBar.overrideUserInterfaceStyle = .dark
    }
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: .main)
        self.selectedIndex = 0
        self.view.addGestureRecognizer(createGestureRecognizer(.left))
        self.view.addGestureRecognizer(createGestureRecognizer(.right))
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func createGestureRecognizer(_ direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        gesture.direction = direction
        return gesture
    }
}

// MARK: - UITabBarControllerDelegate
extension CustomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let fromIndex = self.viewControllers?.firstIndex(of: fromVC),
           let toIndex = self.viewControllers?.firstIndex(of: toVC) {
            let targetEdge: UIRectEdge = toIndex > fromIndex ? .left : .right
            return CustomTabBarAnimator(targetEdge: targetEdge)
        }
        return nil
    }
}

// MARK: - Actions
@objc
private extension CustomTabBarController {
    func didSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            selectedViewController = viewControllers?[(selectedIndex + 1) % viewControllers!.count]
        case .right:
            let index = selectedIndex - 1 < 0 ? viewControllers!.count - 1 : selectedIndex - 1
             selectedViewController = viewControllers?[index]
        case _:
            break
        }
    }
}
