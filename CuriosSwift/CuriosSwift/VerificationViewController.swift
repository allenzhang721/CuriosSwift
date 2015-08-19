//
//  VerificationViewController.swift
//  
//
//  Created by Emiaostein on 8/18/15.
//
//

import UIKit

class VerificationViewController: UIViewController, UINavigationBarDelegate {
  
  var phone: String = ""
  var areaCode: String = ""
  var password: String = ""

  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      title = localString("SMSVERIFY")
      
      let ss = (phone as NSString)
      let secrtPhone = ss.stringByReplacingCharactersInRange(NSMakeRange(0, ss.length - 4), withString: "XXXXXX")
      
      let phonetext = "+ " + areaCode + " " + secrtPhone
      phoneLabel.text = phonetext

      let backImage = UIImage(named: "Template_Back")
      let backItem = UIBarButtonItem(image: backImage, landscapeImagePhone: nil, style: .Plain, target: self, action: "backAction:")
//      navigationItem.backBarButtonItem = backItem
      navigationItem.leftBarButtonItem = backItem
      
        // Do any additional setup after loading the view.
    }
  
  
  @IBAction func tapAction(sender: UITapGestureRecognizer) {
    
    textField.resignFirstResponder()
  }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func backAction(sender: AnyObject) {
    
    let alert = AlertHelper.alert_verifyback { [weak self] (confirm) -> () in
      
      if confirm {
        if let navigation = self?.navigationController as? LaunchNaviViewController {
          navigation.popViewControllerAnimated(true)
        }
      }
      
    }
    
    presentViewController(alert, animated: true, completion: nil)
  }
    

  @IBAction func nextAction(sender: UIButton) {
    
//    showRegisterInfoVC()
    
    let aphone = phone
    let aareaCode = areaCode
    let apassword = password
    CountryCodeHelper.commit(textField.text, compelted: { [weak self] (success) -> () in
      
      if let strongSelf = self {

        if success {
          debugPrint.p("verification is success !")
          
          strongSelf.register(aphone, code: aareaCode, password: apassword)
          
        } else {
          self?.verifyfail()
          debugPrint.p("verification is fail !")
          
        }
      }
    })
  }
  
  func verifyfail() {
    
    let alert = AlertHelper.alert_verifyfail()
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
  
  func showRegisterInfoVC(user: UserModel) {
    if let infoVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("RegisterInfoViewController") as? RegisterInfoViewController {
      
      infoVC.user = user
      navigationController?.pushViewController(infoVC, animated: true)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
