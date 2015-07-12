//
//  TextEditorTransitionAnimation.swift
//  
//
//  Created by Emiaostein on 7/11/15.
//
//

import UIKit

class TextEditorTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
  
  let dismissTransition: Bool
  
  init(dismissed: Bool) {
    dismissTransition = dismissed
    super.init()
    
  }

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    
    return 0.3
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    let containerView = transitionContext.containerView()
    let view = dismissTransition ? transitionContext.viewForKey(UITransitionContextFromViewKey)! : transitionContext.viewForKey(UITransitionContextToViewKey)!
    view.bounds = containerView.bounds
    view.frame.origin = CGPointZero
    view.alpha = dismissTransition ? 1 : 0
    containerView.addSubview(view)
    
    UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
      
      view.alpha = self.dismissTransition ? 0 : 1
      }) { (finished) -> Void in
        
        transitionContext.completeTransition(finished)
    }
    
  }
}
