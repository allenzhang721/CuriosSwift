//
//  TextEditorViewController.swift
//  
//
//  Created by Emiaostein on 7/11/15.
//
//

import UIKit
import SnapKit

class TextEditorViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var toolbar: UIToolbar!
  @IBOutlet weak var textView: UITextView!
  typealias CompletedBlock = (textAttribute, Bool) -> ()
  typealias CancelBlock = () -> ()
  
  var completeBlock: CompletedBlock!
  var cancelBlock: CancelBlock!
  var textAttri: textAttribute!
  var originAttri: textAttribute!
  
  var begainAttriString: NSAttributedString!

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    modalPresentationStyle = .Custom
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }

    override func viewDidLoad() {
        super.viewDidLoad()
      
      textView.attributedText = begainAttriString
      textView.delegate = self
      view.backgroundColor = UIColor.clearColor()
      
//      let tap = UITapGestureRecognizer(target: self, action: "tap:")
//      view.addGestureRecognizer(tap)
      
      textView.becomeFirstResponder()
      textView.alpha = 0
      
      textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
      
      
    }
  
  deinit {
    textView.removeObserver(self, forKeyPath: "contentSize")
     NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewDidAppear(animated: Bool) {
    
    setup()
    UIView.animateWithDuration(0.2, animations: { [unowned self] () -> Void in
      
      self.textView.alpha = 1.0
    })
  }
  
  func setup() {
    
    let height = textView.bounds.height
    let contentHeight = textView.contentSize.height
    if height > contentHeight {
      let topOffset = (height - contentHeight) / 2.0
      let aOffset = topOffset < 0.0 ? 0.0 : topOffset
      textView.contentOffset = CGPoint(x: textView.contentOffset.x, y: -aOffset)
    }
  }
  
  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    let height = textView.bounds.height
    let contentHeight = textView.contentSize.height
    if keyPath == "contentSize" && object as! NSObject == textView && height > contentHeight {
      
      debugPrint.p("content height = \(textView.contentSize.height)")
//      
//      let height = textView.bounds.height
//      let contentHeight = textView.contentSize.height
      let topOffset = (height - contentHeight) / 2.0
      let aOffset = topOffset < 0.0 ? 0.0 : topOffset
      textView.contentOffset = CGPoint(x: textView.contentOffset.x, y: -aOffset)
      
    }
    
  }
  
  
  
  
  func tap(sender: UITapGestureRecognizer) {
    
    textAttri.text = textView.text
    completeBlock(textAttri, !(textAttri == originAttri))
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func cancelAction(sender: UIBarButtonItem) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  @IBAction func confirmAction(sender: UIBarButtonItem) {
    textAttri.text = textView.text
    completeBlock(textAttri, !(textAttri == originAttri))
    
    dismissViewControllerAnimated(true, completion: nil)
    
  }
  
  
  func setAttributeString(textAttrutes: textAttribute) {
    originAttri = textAttrutes
    textAttri = textAttrutes
    begainAttriString = textAttri.attributeString()
  }
  
  func keyboardWillChangeFrame(notification: NSNotification) {
    
    if let userInfo = notification.userInfo {
      
      let endRect = (userInfo["UIKeyboardFrameEndUserInfoKey"] as! NSValue).CGRectValue()
      let height = endRect.height
      textView.snp_updateConstraints({ (make) -> Void in
        make.height.equalTo(self.view.bounds.height - height - 44)
      })
      
      toolbar.snp_updateConstraints({ (make) -> Void in
        make.bottom.equalTo(self.view).offset(-height)
      })
      
    }
  }

}
