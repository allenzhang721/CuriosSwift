//
//  RegisterInfoViewController.swift
//  
//
//  Created by Emiaostein on 8/18/15.
//
//

import UIKit
import Kingfisher

class RegisterInfoViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {

  @IBOutlet weak var launchButton: UIButton!
  var user: UserModel!
  weak var nicknameTextField: UITextField!
  
  let maxCount = 20
  
  @IBOutlet var tapGesture: UITapGestureRecognizer!
  var userIconPath: String {
    
    get {
      let userID = user.userID
      let icon = "icon.jpg"
      let path = pathByComponents([userID, icon])
      return path
    }
  }
  
  var iconImage: UIImage!
  var iconURL: NSString = ""
  
  @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      begain()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func textFieldDidChanged(sender: AnyObject) {
    
//    user.nikename = nicknameTextField.text
    
    let textField = nicknameTextField!
    
    let textCount = (textField.text as NSString).length
    
    if textCount <= maxCount {
      user.nikename = textField.text
    } else {
      let string = textField.text as NSString
      let subString = string.substringWithRange(NSMakeRange(0, min(textCount, maxCount)))
      let subCount = (subString as NSString).length
      textField.text = subString
    }
    
    launchButton.enabled = !user.iconURL.isEmpty && (textCount >= 2 && textCount <= 20) ? true : false
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    textField.resignFirstResponder()
    
    return true
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

  
  
  
  func begain() {
    
    title = localString("INFO")
    
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
    launchButton.enabled = false
  }
  
  @IBAction func tapAction(sender: UITapGestureRecognizer) {
    
    if let nickte = nicknameTextField {
      
      nicknameTextField.resignFirstResponder()
    }
  }
  
  @IBAction func launchAction(sender: AnyObject) {
    let nickname = nicknameTextField.text

    nicknameTextField.resignFirstResponder()
    // upload image & save nickName

    // update userInfo
    if !nickname.isEmpty && !user.iconURL.isEmpty {
      
      user.nikename = nickname
      let iconURL = userIconPath
      
      // upload image
      let data = UIImageJPEGRepresentation(iconImage, 0.01)
      let key = userIconPath
      HUD.register_registering()
      UploadsManager.shareInstance.setCompeletedHandler({ [weak self] (finished) -> () in
        
        if finished {
          // update info
          self?.updateUserInfo(nickname, iconurl: iconURL, completed: { [weak self] (finished, usermodel) -> () in
            if finished {
              HUD.dismiss()
              // launch delegate
              self?.login(usermodel!)
            } else {
              HUD.dismiss()
              self?.showLunchFail()
            }
          })
        }
      })
      
      prepareUploadImageData(data!, key: key, compeletedBlock: { [weak self] (success, theData, theKey, theToken) -> () in
        if success {
          UploadsManager.shareInstance.upload([theData], keys: [theKey], tokens: [theToken])
        } else {
          HUD.dismiss()
          self?.showLunchFail()
        }
        
      })
      
      
    } else {
      // alert
    }
  }
  
  func showLunchFail() {
    
    let alert = AlertHelper.alert_netwrong()
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  func login(launchUser: UserModel) {
    
    debugPrint.p("will launch user = \(user)")
    if let navigation = navigationController as? LaunchNaviViewController {
      navigation.launchDelegate?.navigationController(navigation, loginUser: launchUser)
    }
  }
  
  func prepareUploadImageData(data: NSData, key: String, compeletedBlock:(Bool, NSData, String, String) -> ()) {
    
    let para = GET_IMAGE_TOKEN_paras(key)
    
    ImageTokenRequest.requestWithComponents(GET_IMAGE_TOKEN, aJsonParameter: para) { (json) -> Void in
      
      if let keyTokens = json["list"] as? [[String:String]] {
        
        let keyToken = keyTokens[0]
        let token = keyToken["upToken"]!
        
        compeletedBlock(true, data, key, token)
      } else {
        compeletedBlock(false, NSData(), "", "")
      }
      }.sendRequest()
  }
  
  
  
  func updateUserInfo(nikename: String, iconurl: String, completed:(Bool, UserModel?) -> ()) {
    
    let userID = user.userID
    let nickName = nikename
    let descri = user.descri
    let aiconURL = iconurl
    let sex = "\(user.sex)"
    let countryID = "\(user.countryID)"
    let proviceID = "\(user.provinceID)"
    let cityID = "\(user.cityID)"
    
    let paras = UPDATE_USER_INFO_paras(userID, nickName, descri, aiconURL, sex, countryID, proviceID, cityID)
    UpdateUserInfoRequest.requestWithComponents(UPDATE_USER_INFO, aJsonParameter: paras) { (dic) -> Void in
      
      if let resultTypeStr  = dic["resultType"] as? String where resultTypeStr == "success" {
        let user = RegisterHelper.userBy(dic)
        completed(true, user)
      } else {
        completed(false, nil)
      }
    }.sendRequest()
    
  }
  
  // show Sheet
  private func showsheet() {
    
    let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    if (UIImagePickerController.availableMediaTypesForSourceType(.Camera) != nil) {
      
      let string = localString("CAMERA")
      let CameraAction = UIAlertAction(title: string, style: .Default) { (action) -> Void in
        
        self.showImagePicker(.Camera)
      }
      sheet.addAction(CameraAction)
    }
    
    let libarayString = localString("LIBARAY")
    let LibarayAction = UIAlertAction(title: libarayString, style: .Default) { (action) -> Void in
      
      self.showImagePicker(.PhotoLibrary)
    }
    
    let cancel = localString("CANCEL")
    let CancelAction = UIAlertAction(title: cancel, style: .Cancel) { (action) -> Void in
      
    }
    
    sheet.addAction(LibarayAction)
    sheet.addAction(CancelAction)
    presentViewController(sheet, animated: true, completion: nil)
  }
  
  // show Image Picker
  private func showImagePicker(type: UIImagePickerControllerSourceType) {
    
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = type
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  
  
  
  func configCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    
    switch (indexPath.section, indexPath.row) {
      
    case (0, 0):
      let cell = tableView.dequeueReusableCellWithIdentifier("IconCell") as! UITableViewCell
      if let iconView = cell.viewWithTag(1000) as? UIImageView {
        if iconImage == nil {
          iconView.image = UIImage(named: "placeholder")
        } else {
          iconView.image = iconImage
        }
      }
      
      return cell
    case (1, 0):
      let cell = tableView.dequeueReusableCellWithIdentifier("NicknameCell") as! UITableViewCell
      if let textfield = cell.viewWithTag(1001) as? UITextField {
        nicknameTextField = textfield
        nicknameTextField.delegate = self
        textfield.text = user.nikename
      }
      
      return cell
      
    default:
      return tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    }
  }

}

extension RegisterInfoViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    switch (indexPath.section, indexPath.row) {
    case(0, 0):
      return 108
    default:
      return 44
    }
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    return configCell(tableView, indexPath: indexPath)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    nicknameTextField.resignFirstResponder()
    if indexPath.section == 0 && indexPath.row == 0 {
      
      showsheet()
    }
  }
  
}

extension RegisterInfoViewController: UIImagePickerControllerDelegate {
  
  func thumbnailImage(image: UIImage, size: CGSize) -> UIImage {
    
    UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
    image.drawInRect(CGRect(origin: CGPointZero, size: size))
    let aImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return aImage
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
    let aSelectedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
    let small = thumbnailImage(aSelectedImage, size: CGSize(width: 320, height: 320))
    let imageData = UIImageJPEGRepresentation(small, 0)
    let selectedImage = UIImage(data: imageData)!
    
    user.iconURL = userIconPath
    iconImage = selectedImage

    launchButton.enabled = !user.iconURL.isEmpty && !user.nikename.isEmpty ? true : false
    
    tableView.reloadData()
    dismissViewControllerAnimated(true, completion: nil)
  }
}


extension RegisterInfoViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    switch gestureRecognizer {
      
    case let gesture where gesture == tapGesture:
      let cells = tableView.visibleCells()
      for cell in cells {
        let location = gesture.locationInView(cell as? UIView)
        if CGRectContainsPoint(cell.bounds, location) {
          return false
        }
      }
      return true
    default:
      return true
    }
    
    
  }
  
}