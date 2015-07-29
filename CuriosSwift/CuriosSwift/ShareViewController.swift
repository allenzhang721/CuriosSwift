//
//  ShareViewController.swift
//  
//
//  Created by Emiaostein on 7/28/15.
//
//

import UIKit

class ShareViewController: UIViewController {
  
  enum ShareType {
    case Friends, Timeline, Browser, CopyLink
  }
  
  var shareBlock: ((ShareType) -> ())?
  
  var defaultLayout: UICollectionViewFlowLayout {
    
    let layout = UICollectionViewFlowLayout()
    let number = itemsKey.count
    
    
    let itemWidth: CGFloat = 60.0
    let itemheight: CGFloat = 60.0
    let space = (view.bounds.width - itemWidth * CGFloat(number)) / CGFloat(number + 1)
    let itemLineSpace = space
    let left = space
    let right = left
    let top: CGFloat = 20.0
    let bottom = collectionVIew.bounds.height - itemheight - top
    
    layout.itemSize = CGSize(width: itemWidth, height: itemheight)
    layout.minimumLineSpacing = itemLineSpace
    layout.sectionInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    return layout
    
  }

  @IBOutlet weak var collectionVIew: UICollectionView!
  
  class func create() -> ShareViewController {
    
    let share = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
    share.modalPresentationStyle = .Custom
    share.transitioningDelegate = share
    return share
  }
  
  var itemsKey = ["WeChatFirends", "WeChatTimeline", "OpenInSafari", "CopyLink"]
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      collectionVIew.setCollectionViewLayout(defaultLayout, animated: true)
    }
  
  

  @IBAction func cancelAction(sender: UIBarButtonItem) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  func configCellWith(cell: UICollectionViewCell, key: String) {
    
    if cell.backgroundView == nil {
      let image = UIImage(named: key)
      let imageView = UIImageView(image: image)
      cell.backgroundView = imageView
      
      let label = UILabel(frame: CGRect(x: 0, y: cell.bounds.height + 10, width: cell.bounds.width, height: 0))
      label.tag = 10000
      label.font = UIFont.systemFontOfSize(10)
      label.numberOfLines = 0
      cell.clipsToBounds = false
      cell.contentView.addSubview(label)
      
    }
    
    let label = cell.contentView.viewWithTag(10000) as! UILabel
    let aTitle = localString(key) as NSString
    let attribute = [NSFontAttributeName: label.font]
    let size = aTitle.boundingRectWithSize(CGSize(width: cell.bounds.width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attribute, context: nil).size
    label.text = aTitle as String
    label.textAlignment = .Center
    label.frame.size = size
    label.frame.origin = CGPoint(x: (cell.bounds.width - size.width) / 2.0, y: label.frame.origin.y)
    
  }

}


// MARK: - TransitionDelegate

extension ShareViewController: UIViewControllerTransitioningDelegate {
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return ShareViewControllerPresentAnimation()
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    return nil
  }
  
  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
    
    return nil
  }
  
}


// MARK: - CollectionViewDataSource & CollectionViewDelegate

extension ShareViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return itemsKey.count
    
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("shareCell", forIndexPath: indexPath) as! UICollectionViewCell
    let key = itemsKey[indexPath.item]
    configCellWith(cell, key: key)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let key = itemsKey[indexPath.item]
//    ["WeChatFirends", "WeChatTimeline", "OpenInSafari", "CopyLink"]
    switch key {
      case "WeChatFirends":
        shareBlock?(.Friends)
    case "WeChatTimeline":
      shareBlock?(.Timeline)
    case "OpenInSafari":
      shareBlock?(.Browser)
    case "CopyLink":
      shareBlock?(.CopyLink)
    default:
      return
    }
  }
  
}

class ShareViewControllerPresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    
    return 0.3
    
  }
  // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    let contentView = transitionContext.containerView()
    let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
    toView.bounds.size = CGSize(width: contentView.bounds.width, height: 174)
    toView.frame.origin = CGPoint(x: 0, y: contentView.bounds.height - 174)
    contentView.addSubview(toView)
    toView.transform = CGAffineTransformMakeTranslation(0, toView.bounds.height)
    
    UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
      toView.transform = CGAffineTransformMakeTranslation(0, 0)
      
    }) { (finished) -> Void in
      
      if finished {
        transitionContext.completeTransition(finished)
      }
    }
  }
}
