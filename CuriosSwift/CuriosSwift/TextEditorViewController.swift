//
//  TextEditorViewController.swift
//  
//
//  Created by Emiaostein on 7/11/15.
//
//

import UIKit

class TextEditorViewController: UIViewController {
  
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
      
      let tap = UITapGestureRecognizer(target: self, action: "tap:")
      view.addGestureRecognizer(tap)
      
    }
  
  deinit {
    println("textEditor deinit")
  }
  
  func tap(sender: UITapGestureRecognizer) {
    
    textAttri.text = textView.text
    completeBlock(textAttri, !(textAttri == originAttri))
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func setAttributeString(textAttrutes: textAttribute) {
    originAttri = textAttrutes
    textAttri = textAttrutes
    begainAttriString = textAttri.attributeString()
  }

}
