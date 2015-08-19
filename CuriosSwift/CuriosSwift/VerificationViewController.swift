//
//  VerificationViewController.swift
//  
//
//  Created by Emiaostein on 8/18/15.
//
//

import UIKit

class VerificationViewController: UIViewController {
  
  var phone: String = ""
  var areaCode: String = ""
  var password: String = ""

  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
      let ss = (phone as NSString)
      let secrtPhone = ss.stringByReplacingCharactersInRange(NSMakeRange(0, ss.length - 4), withString: "XXXXXX")
      
      let phonetext = "+ " + areaCode + " " + secrtPhone
      phoneLabel.text = phonetext

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
          debugPrint.p("verification is fail !")
          
        }
      }
    })
    
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
    
    if let navigation = navigationController as? LaunchNaviViewController {
      navigation.launchDelegate?.navigationController(navigation, loginUser: user)
    }
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
