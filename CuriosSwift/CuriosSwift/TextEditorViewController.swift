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
  typealias CompletedBlock = (NSAttributedString) -> ()
  typealias CancelBlock = () -> ()
  
  var completeBlock: CompletedBlock!
  var cancelBlock: CancelBlock!
  
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
    
    completeBlock(textView.attributedText)
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func setAttributeString(attributeString: NSAttributedString) {
    begainAttriString = attributeString
  }

}
