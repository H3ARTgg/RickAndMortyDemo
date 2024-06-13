import UIKit

final class CustomTabBarAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var targetEdge: UIRectEdge

    init(targetEdge: UIRectEdge) {
        self.targetEdge = targetEdge
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let toView = transitionContext.view(forKey: .to) else {
                  return
              }

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)

        let screenWidth = UIScreen.main.bounds.size.width
        toView.frame.origin.x = targetEdge == .left ? screenWidth : -screenWidth
        let finalFrame = transitionContext.finalFrame(for: toVC)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.frame = finalFrame
            fromVC.view.frame.origin.x = self.targetEdge == .left ? -screenWidth : screenWidth
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
