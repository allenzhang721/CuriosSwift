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
    override func viewDidLoad() {
        super.viewDidLoad()

      textField.delegate = self
      textField.becomeFirstResponder()
      
      textField.text = dataSource?.textofTextInputController(self)
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
  
  func textFieldDidChanged(notification: NSNotification) {
    
//    debugPrint.p(textField.text)
    dataSource?.textInputViewControllerTextDidChanged(self, didChangedText: textField.text)
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
