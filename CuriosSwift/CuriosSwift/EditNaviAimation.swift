//
//  EditNaviAimation.swift
//  
//
//  Created by Emiaostein on 7/19/15.
//
//

import UIKit

class EditNaviAimation: NSObject, UIViewControllerAnimatedTransitioning {
  
  let presend: Bool
  
  init(presended: Bool) {
    presend = presended
    super.init()
  }
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    
    return 0.5
  }
  // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    
    let snapShotTag = 10001
    
    let containerView = transitionContext.containerView()
    
    let willShowView = transitionContext.viewForKey(UITransitionContextToViewKey)
    
    let firstVC = presend ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! EditThemeViewController : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! EditThemeViewController
    
    if presend {
      
      let fullSnapshot = firstVC.view.snapshotViewAfterScreenUpdates(false)
      
      let snapshot = firstVC.getSelectedSnapshot()
      snapshot.tag = snapShotTag
      snapshot.userInteractionEnabled = false
      
      let sub = willShowView?.viewWithTag(10003)
      sub?.alpha = 0.0
      
      let blur = willShowView?.viewWithTag(10002)!
      blur!.alpha = 0
      
      
      willShowView!.insertSubview(snapshot, atIndex: 0)
      willShowView?.insertSubview(fullSnapshot, atIndex: 0)
      containerView.addSubview(willShowView!)
      
      
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        
        blur!.alpha = 1.0
        sub?.alpha = 1.0
        snapshot.frame = willShowView!.bounds
        
        }, completion: { (finished) -> Void in
          
          transitionContext.completeTransition(finished)
      })
    } else {
      
      let snapshot = containerView.viewWithTag(snapShotTag)!
      let blur = containerView.viewWithTag(10002)!
      
      let sub = containerView.viewWithTag(10003)
      sub?.alpha = 1.0
      
      let originFrame = firstVC.getSelectedOriginFrame()
      
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        
        snapshot.frame = originFrame
        sub?.alpha = 0.0
        blur.alpha = 0
        
        }, completion: { (finished) -> Void in
          containerView.addSubview(willShowView!)
          transitionContext.completeTransition(finished)
          
      })
    }
  }
}
