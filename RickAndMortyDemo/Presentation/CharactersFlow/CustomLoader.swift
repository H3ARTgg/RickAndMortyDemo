import Lottie
import UIKit

// MARK: - CustomIndicator
final class CustomLoader: LottieAnimationView {
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(animation: .named("loading"))
        loopMode = .loop
        backgroundColor = .rmBlackSecondary.withAlphaComponent(0.75)
        cornerRadius(30)
        alpha = 0
        tag = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Showing loader
    func show(_ isShowing: Bool) {
        let newTag: Int = isShowing ? 0 : 1
        
        // return if state is already set
        guard newTag != tag else { return }
        
        tag = newTag
        let alpha: CGFloat = isShowing ? 1 : 0
        isShowing ? play() : nil
        UIView.animate(withDuration: 0.2) {
            self.alpha = alpha
        } completion: { [weak self] _ in
            isShowing ? nil : self?.stop()
        }
    }
}
