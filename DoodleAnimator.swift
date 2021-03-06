
import UIKit

class DoodleAnimator: NSObject {
    
    typealias CompletionBlock = () -> Void
    
    let duration: Double
    var presenting: Bool = false
    var originFrame: CGRect? = nil
    var imageView: UIImageView? = nil
    var dismissCompletionBlock: CompletionBlock?
    
    init(duration: Double, originatingFrame frame: CGRect? = nil, completion: CompletionBlock? = nil) {
        self.duration = duration
        self.originFrame = frame
        self.dismissCompletionBlock = completion
        super.init()
    }
    
}

extension DoodleAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromViewControler = transitionContext.viewController(forKey: .from)
        let toViewControler = transitionContext.viewController(forKey: .to)
        
        let viewToFade = presenting ? toViewControler : fromViewControler
        
        guard let finalVC = viewToFade as? CanvasViewController else {
            print("viewToFade was not of type: 'CanvasViewController'.")
            transitionContext.completeTransition(false)
            return
        }
        
        containerView.frame = UIScreen.main.bounds
        
        if presenting {
            containerView.addSubview(finalVC.view)
            
            let finalCanvasFrame = finalVC.canvas.frame
            var animatingImageView: UIImageView? = nil
            finalVC.view.alpha = 0
            
            if let frame = originFrame, let imageView = imageView {
                finalVC.canvas.alpha = 0
                finalVC.strokeSlider.alpha = 0
                
                animatingImageView = UIImageView(frame: frame)
                animatingImageView?.image = imageView.image
                
                finalVC.view.insertSubview(animatingImageView!, belowSubview: finalVC.toolbar)
            }
            else {
                finalVC.canvas.frame = CGRect(
                    x: finalVC.canvas.bounds.width * 2,
                    y: finalCanvasFrame.origin.y,
                    width: finalVC.canvas.bounds.width,
                    height: finalVC.canvas.bounds.height
                )
            }
            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                animations: {
                    finalVC.view.alpha = 1
                    finalVC.strokeSlider.alpha = 1

                    animatingImageView?.frame = finalCanvasFrame
                    finalVC.canvas.frame = finalCanvasFrame
                }, completion: { _ in
                    finalVC.canvas.alpha = 1
                    animatingImageView?.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            )
            
        }
        else {            
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                animations: {
                    finalVC.view.alpha = 0.0
                    finalVC.canvas.frame = CGRect(
                        x: -finalVC.canvas.bounds.width,
                        y: finalVC.canvas.frame.origin.y,
                        width: finalVC.canvas.bounds.width,
                        height: finalVC.canvas.bounds.height
                    )
                },
                completion: { _ in
                    transitionContext.completeTransition(true)
                    self.dismissCompletionBlock?()
            })
        }
    }
    
}
