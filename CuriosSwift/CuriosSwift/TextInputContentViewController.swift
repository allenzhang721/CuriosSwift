//
//  TextInputContentViewController.swift
//  
//
//  Created by Emiaostein on 7/29/15.
//
//

import UIKit

class TextInputContentViewController: UIViewController {

  @IBOutlet weak var textCountLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  weak var dataSource: textInputDataSource?
  let maxCount = 30
  var textCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
      
      let text = dataSource?.textofTextInputController(self)
      let count = text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
      textView.text = text
      textCountLabel.text = "\(count)/\(maxCount)"
    }
}

extension TextInputContentViewController: UITextViewDelegate {
  
  func textViewDidChange(textView: UITextView) {
    
    let textCount = textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    textCountLabel.text = "\(textCount)/\(maxCount)"
    dataSource?.textInputViewControllerTextDidChanged(self, didChangedText: textView.text)
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

    let textCount = textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    
    
    if textCount >= maxCount {
      if text == "" || range.length >= 1{
        return true
      }
      return false
    } else {
      return true
    }
  }
}
