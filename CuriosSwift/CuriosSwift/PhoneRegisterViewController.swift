//
//  PhoneLoginViewController.swift
//
//
//  Created by Emiaostein on 8/17/15.
//
//

import UIKit

class PhoneRegisterViewController: UIViewController {
  
  var isLogin = false
  
  var phoneTextField: UITextField!
  var passwordTextField: UITextField!
  
  struct Register {
    var countryDisplayName: String
    var areacode: String
    var phone: String
    var password: String
    
    mutating func updatePhone(number: String) {
      phone = number
    }
    mutating func updatePassword(number: String) {
      password = number
    }
    
    func checkOKWith(zoneCode: String, rule: String) -> Bool {
      
      // get current zone code and rule
      if zoneCode != areacode {
        return false
      }
      
      // basic check: password count
      let passwordLength = password.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
      if passwordLength < 6 || passwordLength > 15 {
        return false
      }
      
      
      // phone rule
      debugPrint.p(rule)
      let predicate = NSPredicate(format: "SELF MATCHES %@", rule)
      if !predicate.evaluateWithObject(phone) {
        return false
      }

      if !areacode.isEmpty && !phone.isEmpty && !password.isEmpty {
        return true
      }
      
      return true
    }
  }
  
  var supportZones: [CountryCodeHelper.Zone] = []
  
  var currentZone: CountryCodeHelper.Zone!
  
  @IBOutlet weak var loginButton: UIButton!
  
  
  var defaultRegister:Register!
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    begain()
    
    loginButton.enabled = false
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
//  override func viewDidAppear(animated: Bool) {
//    func showRegisterInfoVC() {
//      if let infoVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("RegisterInfoViewController") as? RegisterInfoViewController {
//        
//        navigationController?.pushViewController(infoVC, animated: true)
//      }
//      
//      
//    }
//    showRegisterInfoVC()
//  }
  @IBAction func backAction(sender: AnyObject) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  
  @IBAction func tapAction(sender: UITapGestureRecognizer) {
    
    if let phone = phoneTextField {
      phone.resignFirstResponder()
    }
    
    if let passwor = passwordTextField {
      passwor.resignFirstResponder()
    }
    
    
    
  }
  
  
  func begain() {
    
    if isLogin {
      title = localString("LOGIN")
    } else {
      title = localString("REGISTER")
    }
    
    // current areaCode and country name
    let currentZoneInfo = CountryCodeHelper.currentCountryDisplayNameAreaCodeCountryCode()
    let countryName = currentZoneInfo.0
    let areaCode = currentZoneInfo.1
    defaultRegister = Register(countryDisplayName: countryName, areacode: areaCode, phone: "", password: "")
    
    // zone
    CountryCodeHelper.getZone {[weak self] (success, zones) -> () in
      if let strongSelf = self {
        if success {
          strongSelf.supportZones = zones
          strongSelf.updateCurrentZoneWith(areaCode, zones: strongSelf.supportZones)
        }
      }
    }
  }
  
  func updateCurrentZoneWith(zoneCode: String, zones: [CountryCodeHelper.Zone]) {
    
    let currentzone = zones.filter { zone -> Bool in
      
      return zone.zoneCode == zoneCode
    }
    
    if currentzone.count > 0 {
      currentZone = currentzone.first!
      debugPrint.p("currentZone = \(currentZone)")
    }
  }
  
  
  @IBAction func loginAction(sender: UIButton) {
    
    let phone = defaultRegister.phone
    let zone = defaultRegister.areacode
    let password = defaultRegister.password
    
    let encrptPassword = AESCrypt.encrypt(password, password: AESDecrptKey)
    
    if isLogin {
      
      RegisterHelper.phoneLogin(phone, password: encrptPassword, completed: {[weak self] (success, userModel) -> () in
        
        if success {
          self?.login(userModel!)
        } else {
          // acount fail
          self?.showAcountFail()
        }
      })
      
    } else {
      let phones = "+ \(zone) \(phone)"
      
      let alert = AlertHelper.alert_willSendVerify(phones, finished: { [weak self] (confirm) -> () in
        
        if let StrongSelf = self {
          if confirm {
            CountryCodeHelper.getVerificationCodeBySMSWithPhone(phone, zoneCode: zone) {[weak self] (success) -> () in
              if let strongSelf = self {
                if success {
                  self?.showVerificationVC()
                } else {
                  
                }
              }
            }
          }
        }
      })
      
      self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
  }
  
  func showAcountFail() {
    
    let alert = AlertHelper.alert_countfail()
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  func login(user: UserModel) {
    
    if let navigation = navigationController as? LaunchNaviViewController {
      navigation.launchDelegate?.navigationController(navigation, loginUser: user)
    }
  }
  
  func showVerificationVC() {
    
    if let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("VerificationViewController") as? VerificationViewController {
      
      let encrptPassword = AESCrypt.encrypt(defaultRegister.password, password: AESDecrptKey)
      
      vc.phone = defaultRegister.phone
      vc.areaCode = defaultRegister.areacode
      vc.password = encrptPassword
      
//      debugPrint.p(defaultRegister.password)
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func showCountryVC() {
    
    if let countryVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("CountryTableViewController") as? CountryTableViewController {
      
      navigationController?.pushViewController(countryVC, animated: true)
    }
  }
}

extension PhoneRegisterViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if indexPath.item == 0 {
      
      showCountryVC()
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return 3
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.item == 0 {
      if let cell = tableView.dequeueReusableCellWithIdentifier("CountryCell") as? UITableViewCell {
        println("CountryCell")
        cell.detailTextLabel?.textColor = UIColor(hexString: "#4894ED")
        cell.detailTextLabel?.text = defaultRegister.countryDisplayName
        return cell
      }
    }
    
    if indexPath.item == 1 {
      if let cell = tableView.dequeueReusableCellWithIdentifier("PhoneCell") as? UITableViewCell {
        println("PhoneCell")
        cell.textLabel?.text = "+ " + defaultRegister.areacode
        if let textField = cell.viewWithTag(1001) as? UITextField {
          phoneTextField = textField
          if textField.delegate == nil {
            textField.delegate = self
          }
          textField.text = defaultRegister.phone
        }
        return cell
      }
    }
    
    if indexPath.item == 2 {
      if let cell = tableView.dequeueReusableCellWithIdentifier("PasswordCell") as? UITableViewCell {
        println("PasswordCell")
        if let textField = cell.viewWithTag(1002) as? UITextField {
          passwordTextField = textField
          if textField.delegate == nil {
            textField.delegate = self
          }
          textField.text = defaultRegister.password
        }
        return cell
      }
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    return cell
  }
}

extension PhoneRegisterViewController: UITextFieldDelegate {
  
  func textFieldDidChanged(notification: NSNotification) {
    
    let textField = notification.object as! UITextField
    let zoneCode = currentZone.zoneCode
    let rule = currentZone.phoneCheckRule
    if textField.tag == 1001 {
      println(textField.text)
      defaultRegister.updatePhone(textField.text)
      
      if defaultRegister.checkOKWith(zoneCode, rule: rule) {
        loginButton.enabled = true
      } else {
        loginButton.enabled = false
      }
    }
    
    if textField.tag == 1002 {
      println(textField.text)
      defaultRegister.updatePassword(textField.text)
      if defaultRegister.checkOKWith(zoneCode, rule: rule) {
        loginButton.enabled = true
      } else {
        loginButton.enabled = false
      }
    }
  }
}


