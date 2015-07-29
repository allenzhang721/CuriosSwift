//
//  TextEditorViewController.swift
//  
//
//  Created by Emiaostein on 7/11/15.
//
//

import UIKit
import SnapKit

class TextEditorViewController: UIViewController {
  
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
      view.backgroundColor = UIColor.clearColor()
      
//      let tap = UITapGestureRecognizer(target: self, action: "tap:")
//      view.addGestureRecognizer(tap)
      
      textView.becomeFirstResponder()
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
  
  deinit {
     NSNotificationCenter.defaultCenter().removeObserver(self)
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
