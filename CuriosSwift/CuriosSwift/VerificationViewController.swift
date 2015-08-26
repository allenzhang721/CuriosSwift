//
//  VerificationViewController.swift
//  
//
//  Created by Emiaostein on 8/18/15.
//
//

import UIKit
import ReachabilitySwift

enum VerifyType {
  case Register, FindPassword
}

class VerificationViewController: UIViewController {
  
  var type: VerifyType = .Register
  
  var phone: String = ""
  var areaCode: String = ""
  var password: String = ""
  var timer: NSTimer?
  
  var timeCount = 60
  let reachability = Reachability.reachabilityForInternetConnection()
  
  @IBOutlet weak var timeLable: UILabel!
  @IBOutlet weak var reverifyButton: UIButton!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      title = localString("SMSVERIFY")
      
      nextButton.enabled = false
      
      let ss = (phone as NSString)
      let secrtPhone = ss.stringByReplacingCharactersInRange(NSMakeRange(0, ss.length - 4), withString: "XXXXXX")
      
      let phonetext = "+ " + areaCode + " " + secrtPhone
      phoneLabel.text = phonetext

      let backImage = UIImage(named: "Template_Back")
      let backItem = UIBarButtonItem(image: backImage, landscapeImagePhone: nil, style: .Plain, target: self, action: "backAction:")
//      navigationItem.backBarButtonItem = backItem
      navigationItem.leftBarButtonItem = backItem
      
        // Do any additional setup after loading the view.
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
      
      begainTimer()
  }
  
//  override func viewDidAppear(animated: Bool) {
//    
//    register( "1111111111", code: "1", password: "jZae727K08KaOmKSgOaGzww/XVqGr/PKEgIMkjrcbJI=")
//  }
  
  deinit {
    timer?.invalidate()
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewDidDisappear(animated: Bool) {
    
    timeCount = 60
    timeLable.hidden = true
    reverifyButton.hidden = false
    timeLable.text = localString("RESENDINGSMS")
    reverifyButton.userInteractionEnabled = true
    timer!.fireDate = NSDate.distantFuture() as! NSDate
    
  }

  

  
  
  
  
  

}

// MARK: - 1. IBAction Method
extension VerificationViewController {
  
  // MARK: - Button
  @IBAction func nextAction(sender: UIButton) {
    
    let result = willNextStep()
    
    if result.0 == false {
      return
    }
    
    let phone = result.1!
    let areaCode = result.2!
    let password = result.3!
    
    didNextStep(phone, areaCode: areaCode, password: password)
  }
  
  func backAction(sender: AnyObject) {
    
    textField.resignFirstResponder()
    let alert = AlertHelper.alert_verifyback { [weak self] (confirm) -> () in
      
      if confirm {
        if let navigation = self?.navigationController as? LaunchNaviViewController {
          navigation.popViewControllerAnimated(true)
        }
      }
      
    }
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - Gestures
  @IBAction func tapAction(sender: UITapGestureRecognizer) {
    
    textField.resignFirstResponder()
  }
  
  
}

// MARK: - 2. DataSource & Delegate
extension VerificationViewController: UINavigationBarDelegate {
  
  // MARK: - Text Field
  func textFieldDidChanged(sender: AnyObject) {
    
    let count = textField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    if count < 4 || count > 6 {
      nextButton.enabled = false
    } else {
      nextButton.enabled = true
    }
  }
  @IBAction func reverifyAction(sender: AnyObject) {
    
    resend {[weak self] (success) -> () in
      
      if let strongSelf = self {
        if success {
          strongSelf.begainTimer()
        }
      }
    }
  }
  
}

// MARK: - 3. Function Method
extension VerificationViewController {
  
  
  // MARK: - Next Step
  func willNextStep() -> (Bool, String?, String?, String?) {  // needNextStep, Phone, areaCode, password
    
    if reachability.currentReachabilityStatus == .NotReachable {
      self.shownetwrongandverifyfail()
      return (false, nil, nil, nil)
    }
    
    let aphone = phone
    let aareaCode = areaCode
    let apassword = password
    
    return (true, aphone, aareaCode, apassword)
    
  }
  
  func didNextStep(phone: String, areaCode: String, password: String) {
    
    switch type {
    case .Register:
      didNextStepRegister(phone, areaCode: areaCode, password: password)
    case .FindPassword:
      didNextStepFindPassword(phone, areaCode: areaCode, password: password)
    }
  }
  
  func didNextStepRegister(phone: String, areaCode: String, password: String) {
    
    CountryCodeHelper.commit(textField.text, compelted: { [weak self] (success) -> () in
      if let strongSelf = self {
        if success {
//          debugPrint.p("verification is success !")
          strongSelf.register(phone, code: areaCode, password: password)
          
        } else {
          self?.showverifyfail()
//          debugPrint.p("verification is fail !")
          
        }
      }
      })
  }
  
  func didNextStepFindPassword(phone: String, areaCode: String, password: String) {
  
    CountryCodeHelper.commit(textField.text, compelted: { [weak self] (success) -> () in
      if let strongSelf = self {
        if success {
//          debugPrint.p("verification is success !")
          strongSelf.showChangedPasswordVC(phone)
          
        } else {
          self?.showverifyfail()
//          debugPrint.p("verification is fail !")
          
        }
      }
      })
  }
  
  
  // MARK: - Timer
  
  func resend(successblock: (Bool) -> ()) {
    HUD.register_sending()
    CountryCodeHelper.getVerificationCodeBySMSWithPhone(phone, zoneCode: areaCode) {[weak self] (success) -> () in
      HUD.dismiss()
      successblock(success)
    }
  }
  
  func begainTimer() {
    
    if timer == nil {
      timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateReverifyLabel", userInfo: nil, repeats: true)
    }
    
    timeLable.hidden = false
    reverifyButton.hidden = true
    reverifyButton.userInteractionEnabled = false
    timer!.fireDate = NSDate.distantPast() as! NSDate
    //    timer!.fire()
  }
  
  func updateReverifyLabel() {
    
    
    timeLable.text = "\(timeCount)"
    
    timeCount--
    
    if timeCount == 0 {
      timeCount = 60
      
      timeLable.hidden = true
      reverifyButton.hidden = false
      timeLable.text = localString("RESENDINGSMS")
      reverifyButton.userInteractionEnabled = true
      timer!.fireDate = NSDate.distantFuture() as! NSDate
    }
  }
  
  func login(user: UserModel) {
    
    let alert = AlertHelper.alert_hasRegistered { [weak self] (confirm) -> () in
      
      if confirm {
        if let navigation = self?.navigationController as? LaunchNaviViewController {
          navigation.launchDelegate?.navigationController(navigation, loginUser: user)
        }
      }
    }
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func register(phone: String, code: String, password: String) {
    
    RegisterHelper.phoneRegister(phone, areaCode: code, password: password) { [weak self] (success, registered,userModel) -> () in
      
      if success {
        
        if registered {
          self?.login(userModel!)
        } else {
          self?.showRegisterInfoVC(userModel!)
        }
      }
    }
  }
  
  // MARK: - Show ViewController
  
  func showRegisterInfoVC(user: UserModel) {
    if let infoVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("RegisterInfoViewController") as? RegisterInfoViewController {
      
      infoVC.user = user
      navigationController?.pushViewController(infoVC, animated: true)
    }
  }
  
  func showChangedPasswordVC(phone: String) {
    
    // TODO: 08.21.2015, Show Change password vc
//    ResetPasswordViewController
    if let resetVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("ResetPasswordViewController") as? ResetPasswordViewController {
      
      resetVC.phone = phone
      navigationController?.pushViewController(resetVC, animated: true)
    }
    
//    debugPrint.p("showChangedPasswordVC")
  }
  
  
  // MARK: - Show Alert
  func shownetwrongandverifyfail() {
    
    let alert = AlertHelper.alert_netwrongandverifyfail()
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func showverifyfail() {
    
    let alert = AlertHelper.alert_verifyfail()
    presentViewController(alert, animated: true, completion: nil)
  }
  
  
}

// MARK: - 4. Helper Method
extension VerificationViewController {

  
}
