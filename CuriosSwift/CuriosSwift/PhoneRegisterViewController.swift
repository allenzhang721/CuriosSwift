//
//  PhoneLoginViewController.swift
//
//
//  Created by Emiaostein on 8/17/15.
//
//

import UIKit
import ReachabilitySwift

enum Type {
  case Register, Login, FindPassword
}

class PhoneRegisterViewController: UIViewController {
  

  var isLogin = false
  var type: Type = .Register  // Login, FindPassword
  
  let findPasswordButtonTag = 3000
  
  @IBOutlet var tapGesture: UITapGestureRecognizer!
  @IBOutlet weak var findPasswordButton: UIButton!
  @IBOutlet weak var nextStepButton: UIButton!
  weak var areaCodeLabel: UILabel!
  weak var phoneTextField: UITextField?
  weak var passwordTextField: UITextField?
  let reachability = Reachability.reachabilityForInternetConnection()
  
  struct Register {
    var countryDisplayName: String
    var areacode: String // 86
    var phone: String
    var password: String
    
    mutating func updateCountryName(aname: String) {
      countryDisplayName = aname
    }
    
    mutating func updateAreaCode(code: String) {
      areacode = code
    }
    
    mutating func updatePhone(number: String) {
      
      phone = number
    }
    mutating func updatePassword(number: String) {
      password = number
    }

    func checkOKWith(zoneCode: String, rule: String, checkPassword: Bool = true) -> Bool {
      
      if !(!countryDisplayName.isEmpty && !areacode.isEmpty && !phone.isEmpty && !password.isEmpty) {
        return false
      }
      
      // get current zone code and rule
      if zoneCode != areacode {
        return false
      }
      
      if checkPassword {
        // basic check: password count
        let passwordLength = password.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if passwordLength < 6 || passwordLength > 16 {
          return false
        }
      }
      
      // phone rule
      let predicate = NSPredicate(format: "SELF MATCHES %@", rule)
      if !predicate.evaluateWithObject(phone) {
        return false
      }
      
      return true
    }
  }
  
  var supportZones: [CountryCodeHelper.Zone] = []
  var currentZone: CountryCodeHelper.Zone?
  
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  var defaultRegister:Register!
  
  

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    begainDidLoad()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}





// MARK: - 1. IBAction Method
extension PhoneRegisterViewController {
  
  // MARK: - Button
  @IBAction func loginAction(sender: UIButton?) {
    
    cancelFirstResponder()
    
    let result = beforeLoginAndRegister() // need next step
    if result.0 == false {
      return
    }
    
    let phone = result.1!
    let zone = result.2!
    let encryptPassword = result.3!
    
    switch type {
    case .Register:
      begainRegister(
        phone,
        zone: zone,
        encryptPassword: encryptPassword)
    case .Login:
      begainLogin(
        phone,
        zone: zone,
        encryptPassword: encryptPassword)
    case .FindPassword:
      begainFindPassword(
        phone,
        zone: zone)
    default:
      ()
    }
    
  }
  
  @IBAction func backAction(sender: AnyObject) {
    
    cancelFirstResponder()
    
    if type == .FindPassword {
      navigationController?.popViewControllerAnimated(true)
    } else {
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  func findPasswordAction(sender: AnyObject) {
    cancelFirstResponder()
    showFindPasswordVC()
  }

  // MARK: - Gestures
  @IBAction func tapAction(sender: UITapGestureRecognizer) {
    
    cancelFirstResponder()
  }
}



// MARK: - 2. DataSource & Delegate

extension PhoneRegisterViewController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate,CountriesViewControllerDelegate {
  
  // MARK: - TableView
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if indexPath.item == 0 {
      
      showCountriesVC()
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch type {
    case .FindPassword:
      return 2
    default:
      return 3
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.item == 0 {
      if let cell = tableView.dequeueReusableCellWithIdentifier("CountryCell") as? UITableViewCell {
        println("CountryCell")
//        cell.detailTextLabel?.textColor = UIColor(hexString: "#4894ED")
        let countryName = defaultRegister.countryDisplayName
        cell.detailTextLabel?.text = countryName.isEmpty ? localString("SELECTCOUNTRY") : countryName
        return cell
      }
    }
    
    if indexPath.item == 1 {
      if let cell = tableView.dequeueReusableCellWithIdentifier("PhoneCell") as? UITableViewCell {
        println("PhoneCell")
        
        
        if let label = cell.viewWithTag(1002) as? UILabel {
          areaCodeLabel = label
          let areaCode = defaultRegister.areacode
          areaCodeLabel.text = areaCode.isEmpty ? "+ ?" : "+ " + defaultRegister.areacode
        }
        
        if let textField = cell.viewWithTag(2001) as? UITextField {
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
        if let textField = cell.viewWithTag(2002) as? UITextField {
          passwordTextField = textField
          if textField.delegate == nil {
            textField.delegate = self
          }
          textField.text = defaultRegister.password
        }
        
//        if let button = cell.viewWithTag(findPasswordButtonTag) as? UIButton {
//          
//        }
        
        return cell
      }
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    return cell
  }
  
  // MARK: - TextField
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == phoneTextField {
      passwordTextField?.becomeFirstResponder()
    } else {
      phoneTextField?.resignFirstResponder()
      passwordTextField?.resignFirstResponder()
//      loginAction(nil)
    }
    return true
  }
  
  func textFieldDidChanged(notification: NSNotification) {
    
    if currentZone == nil {
      return
    }
    
    let textField = notification.object as! UITextField
    let zoneCode = currentZone!.zoneCode
    let rule = currentZone!.phoneCheckRule
    if textField.tag == 2001 {
      //      println(textField.text)
      let remove = removeBlank(textField.text)
      defaultRegister.updatePhone(remove)
      textField.text = appendBlank(remove)
      if defaultRegister.checkOKWith(zoneCode, rule: rule, checkPassword: !(type == .FindPassword)) {
        loginButton.enabled = true
      } else {
        loginButton.enabled = false
      }
    }
    
    if textField.tag == 2002 {
      defaultRegister.updatePassword(textField.text)
      if defaultRegister.checkOKWith(zoneCode, rule: rule, checkPassword: !(type == .FindPassword)) {
        loginButton.enabled = true
      } else {
        loginButton.enabled = false
      }
    }
  }
  
  // MARK: - Gestures
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    
    switch gestureRecognizer {
    case let gesture where gesture == tapGesture:
      return passwordTextField?.isFirstResponder() ?? false || phoneTextField?.isFirstResponder() ?? false
      
    default:
      return false
    }
  }
  
  
  // MARK: - Countries
  func countriesViewController(viewController: CountriesViewController, didSelectedZoneCode zoneCode: String, countryName name: String) {
    
    defaultRegister.updateAreaCode(zoneCode)
    defaultRegister.updateCountryName(name)
    updateCurrentZoneWith(zoneCode, zones: supportZones)
    tableView.reloadData()
    
    let zoneCode = currentZone!.zoneCode
    let rule = currentZone!.phoneCheckRule
    if defaultRegister.checkOKWith(zoneCode, rule: rule, checkPassword: !(type == .FindPassword)) {
      loginButton.enabled = true
    } else {
      loginButton.enabled = false
    }
    navigationController?.popViewControllerAnimated(true)
  }
  
}

// MARK: - 3. Function Method
extension PhoneRegisterViewController {
  
  // MARK: - Life Cycle
  
  func begainDidLoad() {
    
    loginButton.enabled = false
    
    findPasswordButton.hidden = type == .Login ? false : true
    findPasswordButton.addTarget(self, action: "findPasswordAction:", forControlEvents: UIControlEvents.TouchUpInside)
    
    if isLogin {
      
    } else {
      
    }
    
    switch type {
    case .Login:
      title = localString("LOGIN")
      nextStepButton.setTitle(localString("LOGIN"), forState: UIControlState.Normal)
    case .Register:
      title = localString("REGISTER")
      nextStepButton.setTitle(localString("NEXTSTEP"), forState: UIControlState.Normal)
    case .FindPassword:
      title = localString("FINDPASSWROD")
      nextStepButton.setTitle(localString("NEXTSTEP"), forState: UIControlState.Normal)
    default:
      ()
    }
    
    // current areaCode and country name
    let currentZoneInfo = CountryCodeHelper.currentCountryDisplayNameAreaCodeCountryCode()
    let countryName = currentZoneInfo.0
    let areaCode = currentZoneInfo.1
    defaultRegister = Register(countryDisplayName: countryName, areacode: areaCode, phone: "", password: "")
    
    // zone
    HUD.register_getZoneInfo()
    CountryCodeHelper.getZone {[weak self] (success, zones) -> () in
      
      if let strongSelf = self {
        
        if success {
          HUD.dismiss(0.5)
          strongSelf.supportZones = zones
          strongSelf.updateCurrentZoneWith(areaCode, zones: strongSelf.supportZones)
        } else {
          HUD.dismiss(0.5)
          //          HUD.register_getZoneInfoFail()
          strongSelf.showFailGetZone()
        }
      } else {
        HUD.dismiss(0.5)
      }
    }
  }
  
  // MARK: - Country Code
  
  
  // MARK: - Find Password
  
  private func begainFindPassword(phone: String, zone: String) {
    
    let phones = "+ \(zone) \(phone)"
    let alert = AlertHelper.alert_willSendVerify(phones, finished: { [weak self] (confirm) -> () in
      
      if let StrongSelf = self {
        if confirm {
          HUD.register_sending()
          CountryCodeHelper.getVerificationCodeBySMSWithPhone(phone, zoneCode: zone) {[weak self] (success) -> () in
            HUD.dismiss(0.5)
            if let strongSelf = self {
              if success {
                self?.showVerifyFindPasswordVC(phone, areaCode: zone)
              } else {
                self?.showSMSFail()
              }
            }
          }
        }
      }
      })
    self.presentViewController(alert, animated: true, completion: nil)
    
    
    
  }
  
  // MARK: - Login & Register
  
  private func beforeLoginAndRegister() -> (Bool, String?, String?, String?) {  // needNextStep, phone, zone, encryptPassword
  
    if reachability.currentReachabilityStatus == .NotReachable {
      self.shownetwrongandverifyfail()
      return (false, nil, nil, nil)
    }
    
    let phone = defaultRegister.phone
    let zone = defaultRegister.areacode
    let password = defaultRegister.password
    let encrptPassword = AESCrypt.hash256(defaultRegister.password)
    
    return (true, phone, zone, encrptPassword)
  }
  
  private func begainLogin(phone: String, zone: String, encryptPassword: String) {
    
    HUD.launch_Loading()
    RegisterHelper.phoneLogin(phone, password: encryptPassword, completed: {[weak self] (success, userModel) -> () in
      
      HUD.dismiss()
      if success {
        self?.login(userModel!)
      } else {
        // acount fail
        self?.showAcountFail()
      }
      })
  }
  
  private func begainRegister(phone: String, zone: String, encryptPassword: String) {
    
    let phones = "+ \(zone) \(phone)"
    let alert = AlertHelper.alert_willSendVerify(phones, finished: { [weak self] (confirm) -> () in
      
      if let StrongSelf = self {
        if confirm {
          HUD.register_sending()
          CountryCodeHelper.getVerificationCodeBySMSWithPhone(phone, zoneCode: zone) {[weak self] (success) -> () in
            HUD.dismiss(0.5)
            if let strongSelf = self {
              if success {
                self?.showVerificationVC()
              } else {
                self?.showSMSFail()
              }
            }
          }
        }
      }
      })
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  private func login(user: UserModel) {
    
    if let navigation = navigationController as? LaunchNaviViewController {
      navigation.launchDelegate?.navigationController(navigation, loginUser: user)
    }
  }
  
  func updateCurrentZoneWith(zoneCode: String, zones: [CountryCodeHelper.Zone]) {
    
    let currentzone = zones.filter { zone -> Bool in
      
      return zone.zoneCode == zoneCode
    }
    
    if currentzone.count > 0 {
      currentZone = currentzone.first!
    }
  }
  
  
  
  // MARK: - FirstResponder
  func cancelFirstResponder() {
    
    if let phone = phoneTextField {
      phone.resignFirstResponder()
    }
    
    if let passwor = passwordTextField {
      passwor.resignFirstResponder()
    }
  }
  
  
  // MARK: - Show ViewController
  
  func showCountriesVC() {
    
    if let contriesVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("CountriesViewController") as? CountriesViewController {
      contriesVC.selectedDelegate = self
      navigationController?.pushViewController(contriesVC, animated: true)
    }
  }
  
  func showVerificationVC() {
    
    if let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("VerificationViewController") as? VerificationViewController {
      
      //      let encrptPassword = AESCrypt.encrypt(defaultRegister.password, password: AESDecrptKey)
      let encrptPassword = AESCrypt.hash256(defaultRegister.password)
      vc.type = .Register
      vc.phone = defaultRegister.phone
      vc.areaCode = defaultRegister.areacode
      vc.password = encrptPassword
      
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  func showCountryVC() {
    
    if let countryVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("CountryTableViewController") as? CountryTableViewController {
      
      navigationController?.pushViewController(countryVC, animated: true)
    }
  }
  
  func showFindPasswordVC() {
    
    if let findPasswordVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("PhoneRegisterViewController") as? PhoneRegisterViewController {
      findPasswordVC.type = .FindPassword
      navigationController?.pushViewController(findPasswordVC, animated: true)
    }
  }
  
  // TODO: 08.21.2015, 3. Show SMSVerifyVC as! VerifyViewController
  func showVerifyFindPasswordVC(phone: String, areaCode: String) {
    if let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("VerificationViewController") as? VerificationViewController {
      
      //      let encrptPassword = AESCrypt.encrypt(defaultRegister.password, password: AESDecrptKey)
      let encrptPassword = AESCrypt.hash256(defaultRegister.password)
      vc.type = .FindPassword
      vc.phone = phone
      vc.areaCode = areaCode
      vc.password = encrptPassword
      
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  // MARK: - Show Alert
  private func showFailGetZone() {
    
    let alert = AlertHelper.alert_failGetZone {[weak self] (finished) -> () in
      
      //      if let strongself = self {
      //        strongself.dismissViewControllerAnimated(true, completion: nil)
      //      }
    }
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func shownetwrongandverifyfail() {
    
    let alert = AlertHelper.alert_netwrongandverifyfail()
    presentViewController(alert, animated: true, completion: nil)
  }
  
  private func showAcountFail() {
  
  let alert = AlertHelper.alert_countfail()
  presentViewController(alert, animated: true, completion: nil)
  
  }
  
  func showSMSFail() {
    
    let alert = AlertHelper.alert_smsfail()
    presentViewController(alert, animated: true, completion: nil)
  }
  
}


// MARK: - 4. Helper Method
extension PhoneRegisterViewController: UITextFieldDelegate {
  
  
  func removeBlank(string: String) -> String {
    
    let astring = string as NSString
    let afterString = astring.stringByReplacingOccurrencesOfString(" ", withString: "")
    return afterString
  }
  
  func appendBlank(string: String) -> String {
    
    let afterString = removeBlank(string)
    let count = afterString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    if count <= 3 || count > 11 {
      return afterString
    }
    
    let aString = afterString as NSString
    var indexs = [Int]()
    switch count {
    case let a where a > 3 && a <= 7:
      indexs = [0,3]
      
    case let a where a > 7 && a <= 11:
      indexs = [0, 3, 7]
    default:
      indexs = [0, 3, 7]
    }
    
    var subStrings = [String]()
    for index in indexs {
      let remainCount = count - index
      let isFirst: Bool = index == 0
      let length = isFirst ? (remainCount > 3 ? 3 : remainCount) : (remainCount > 4 ? 4 : remainCount)
      let sub = aString.substringWithRange(NSMakeRange(index, length))
      subStrings.append(sub)
    }
    
    
    let blank = subStrings.reduce("", combine: { (before: String, subString: String) -> String in
      
      if before.isEmpty {
        return subString
      } else {
        return before + " " + subString
      }
    })
    
    return blank
  }
  
  
}


