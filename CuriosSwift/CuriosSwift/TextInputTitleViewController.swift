//
//  TextInputTitleViewController.swift
//  
//
//  Created by Emiaostein on 7/29/15.
//
//

import UIKit

class TextInputTitleViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var textField: UITextField!
  weak var dataSource: textInputDataSource?
  let maxCount = 20
    override func viewDidLoad() {
        super.viewDidLoad()

      textField.delegate = self
      textField.becomeFirstResponder()
      
      textField.text = dataSource?.textofTextInputController(self)
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
  
  func textFieldDidChanged(notification: NSNotification) {
    
    let textCount = (textField.text as NSString).length
    
    if textCount <= maxCount {
      dataSource?.textInputViewControllerTextDidChanged(self, didChangedText: textField.text)
    } else {
      let string = textField.text as NSString
      let subString = string.substringWithRange(NSMakeRange(0, min(textCount, maxCount)))
      let subCount = (subString as NSString).length
      textField.text = subString
    }
    
    
    
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    let textCount = (textField.text as NSString).length
    
    if textCount >= maxCount {
      if string == "" || range.length >= 1{
        return true
      }
      return false
    } else {
      return true
    }
    
  }
  
  
  
  deinit {
    
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
