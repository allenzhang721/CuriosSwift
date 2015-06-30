//
//  UploadSettingAnimation.swift
//  
//
//  Created by Emiaostein on 6/30/15.
//
//

import UIKit

class UploadSettingAnimation: NSObject, UIViewControllerAnimatedTransitioning {
   
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        toView?.bounds.size = CGSize(width: 280, height: 274)
        toView?.center = CGPoint(x: containerView.center.x, y: 210)
        toView?.transform = CGAffineTransformMakeTranslation(0, -(210 + 210))
        
        containerView.addSubview(toView!)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            
            toView?.transform = CGAffineTransformMakeTranslation(0, 0)
        }) { (finished) -> Void in
            
                transitionContext.completeTransition(finished)
            
        }
    }
}
