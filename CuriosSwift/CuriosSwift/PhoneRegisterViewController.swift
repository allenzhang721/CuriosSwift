//
//  PhoneLoginViewController.swift
//  
//
//  Created by Emiaostein on 8/17/15.
//
//

import UIKit

class PhoneRegisterViewController: UIViewController {
  
  struct Register {
    var areacode: String
    var phone: String
    var password: String
    
    mutating func updatePhone(number: String) {
      phone = number
    }
    mutating func updatePassword(number: String) {
      password = number
    }
    
    func checkOK() -> Bool {
      
      if phone.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 11 {
        return false
      }
      
      let passwordLength = password.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
      if passwordLength < 6 || passwordLength > 16 {
        return false
      }
      
      if !areacode.isEmpty && !phone.isEmpty && !password.isEmpty {
        return true
      }
      
      return true
    }
  }
  
  let countryCodes = CountryAndAreaCode()
  
  @IBOutlet weak var loginButton: UIButton!
  
  
  var defaultRegister = Register(areacode: "86", phone: "", password: "")
  
  @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      loginButton.enabled = false
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  @IBAction func loginAction(sender: UIButton) {
    
    
  }
  
  
  func showCountryVC() {
    
    if let countryVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("CountryTableViewController") as? CountryTableViewController {
      
      navigationController?.pushViewController(countryVC, animated: true)
      
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

extension PhoneRegisterViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if indexPath.item == 0 {
      
      showCountryVC()
    }
    
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return 3
  }
  
  // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
  // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.item == 0 {
      if let cell = tableView.dequeueReusableCellWithIdentifier("CountryCell") as? UITableViewCell {
        println("CountryCell")
        return cell
      }
    }
    
    if indexPath.item == 1 {
    if let cell = tableView.dequeueReusableCellWithIdentifier("PhoneCell") as? UITableViewCell {
      println("PhoneCell")
      if let textField = cell.viewWithTag(1001) as? UITextField where textField.delegate == nil {
        textField.delegate = self
      }
      return cell
    }
    }
    
    if indexPath.item == 2 {
    if let cell = tableView.dequeueReusableCellWithIdentifier("PasswordCell") as? UITableViewCell {
      println("PasswordCell")
      if let textField = cell.viewWithTag(1000) as? UITextField where textField.delegate == nil {
        textField.delegate = self
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
    
    if textField.tag == 1001 {
      println(textField.text)
      defaultRegister.updatePhone(textField.text)
      if defaultRegister.checkOK() {
        loginButton.enabled = true
      } else {
        loginButton.enabled = false
      }
    }
    
    if textField.tag == 1000 {
      println(textField.text)
      defaultRegister.updatePassword(textField.text)
      if defaultRegister.checkOK() {
        loginButton.enabled = true
      } else {
        loginButton.enabled = false
      }
    }
    
  }
  
//  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//    
//    
//    
//    if textField.tag == 1001 {
//      println(textField.text)
//      defaultRegister.updatePhone(textField.text)
//      if defaultRegister.checkOK() {
//        loginButton.enabled = true
//      } else {
//        loginButton.enabled = false
//      }
//    }
//    
//    if textField.tag == 1000 {
//      println(textField.text)
//      defaultRegister.updatePassword(textField.text)
//      if defaultRegister.checkOK() {
//        loginButton.enabled = true
//      } else {
//        loginButton.enabled = false
//      }
//    }
//    
//    
//    return true
//  }
  
}


