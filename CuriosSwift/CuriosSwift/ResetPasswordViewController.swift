//
//  ResetPasswordViewController.swift
//  
//
//  Created by Emiaostein on 8/21/15.
//
//

import UIKit
import ReachabilitySwift

class ResetPasswordViewController: UIViewController {

  var phone: String!
  var password: String!
  let reachability = Reachability.reachabilityForInternetConnection()
  // MARK: - IBOutlet
  @IBOutlet weak var finishButton: UIButton!
  @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

      finishButton.enabled = false
      textField.becomeFirstResponder()
        // Do any additional setup after loading the view.
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

// MARK: - IBAction Method
extension ResetPasswordViewController {
  
  // MARK: - Button
  @IBAction func finishedAction(sender: AnyObject) {
    
    // TODO: 08.21.2015, Check network
    if reachability.currentReachabilityStatus == .NotReachable {
      self.showNetWrong()
      return
    }
    
    
    // TODO: 08.21.2015, sendrequest success or not
    sendChangedPasswordRequest {[weak self] (success) -> () in
      
      if success {
        // back
        self?.backToRoot()
      } else {
        // fail alert
        self?.showFail()
      }
    }
  }
}

// MARK: - Function Method
extension ResetPasswordViewController {
  
  // MARK: - Request
  func sendChangedPasswordRequest(success: (Bool) -> ()) {
    
    let aPhone = phone
    let encryptPassword = AESCrypt.hash256(password)
    
    HUD.register_sending()
    
    let paras = USER_CHANGEPASSWORD_PHONE_paras(aPhone, encryptPassword)
    ChangePasswordRequest.requestWithComponents(USER_CHANGEPASSWORD_PHONE, aJsonParameter: paras) { (json) -> Void in
      
      HUD.dismiss()
      if let resultType = json["resultType"] as? String where resultType == "success" {
        success(true)
      } else {
        success(false)
      }
    }.sendRequest()
  }
  
  func backToRoot() {
    navigationController?.popToRootViewControllerAnimated(true)
  }
  
  // MARK: - Show Alert
  func showFail() {
    let alert = AlertHelper.alert_modifyFail()
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func showNetWrong() {
    let alert = AlertHelper.alert_netwrongandverifyfail()
    presentViewController(alert, animated: true, completion: nil)
  }
}


// MARK: - Datasource and Delegate
extension ResetPasswordViewController {
  
  // MARK: - Text Field
  func textFieldDidChanged(sender: AnyObject) {
    
    let count = textField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    if count < 6 || count > 16 {
      finishButton.enabled = false
    } else {
      password = textField.text
      finishButton.enabled = true
    }
  }
}


// MARK: - Help Method