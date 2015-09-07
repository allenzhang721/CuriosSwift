//
//  LoginViewController.swift
//  Curios
//
//  Created by Emiaostein on 6/2/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import ReachabilitySwift

class LoginViewController: UIViewController, IRegisterDelegate, LaunchDelegate {
  
  
  @IBOutlet weak var phoneLoginView: UIView!
  @IBOutlet weak var wechatLoginButton: UIButton!
  @IBOutlet weak var moreButton: UIButton!
  
  let reachability = Reachability.reachabilityForInternetConnection()
  @IBOutlet weak var breathView: RippleView!
  override func viewDidLoad() {
    super.viewDidLoad()

    
  }
  
  override func viewWillAppear(animated: Bool) {
    setup()
  }
  
  func setup() {
    
    phoneLoginView.hidden = true
    wechatLoginButton.hidden = true
    breathView.hidden = true
    moreButton.hidden = true
    
    if !WXApi.isWXAppInstalled() {
      
      showPhoneLogin()
    } else {
      showWechatLogin()
//      showPhoneLogin()
    }
  }
  
  func showPhoneLogin() {
    
    phoneLoginView.hidden = false
    wechatLoginButton.hidden = true
    breathView.hidden = true
    moreButton.hidden = true
    
  }
  
  func showWechatLogin() {
    
    phoneLoginView.hidden = true
    wechatLoginButton.hidden = false
    breathView.hidden = false
    moreButton.hidden = false
    breathView.addBreathAnimation()
    
  }
  
  @IBAction func PhoneLoginAction(sender: AnyObject) {
    
    showPhoneRegisterVC("Login")
  }
  
  @IBAction func phoneRegisterAction(sender: AnyObject) {
    
    showPhoneRegisterVC("Register")
  }
  
  
  @IBAction func moreLoginAction(sender: UIButton) {
    
    // show more login in options
    showMoreLogin()
    
  }

  func navigationController(controller: LaunchNaviViewController, loginUser user: UserModel) {
    
    saveUserInfo(user)
    controller.dismissViewControllerAnimated(false, completion: nil)
  }
  
  func navigationControllerDidNetBroken(controller: LaunchNaviViewController) {
//    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func showMoreLogin() {
    
//    LOGIN = "登录";
//    REGISTER = "注册";
//    CANCEL

    let login = UIAlertAction(title: localString("LOGIN"), style: .Default) {[unowned self] (action) -> Void in
      
      self.showPhoneRegisterVC("Login")
    }
    
    let register = UIAlertAction(title: localString("REGISTER"), style: .Default) {[unowned self] (action) -> Void in
      
      self.showPhoneRegisterVC("Register")
    }
    
    let cancel = UIAlertAction(title: localString("CANCEL"), style: .Cancel) { (action) -> Void in
      
    }
    
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    alert.addAction(login)
    alert.addAction(register)
    alert.addAction(cancel)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func needConnectNet() {
    
    let alert = AlertHelper.alert_needConnected()
    presentViewController(alert, animated: true, completion: nil)
    
  }
  
  func showPhoneRegisterVC(type: String) {
    
//    if reachability.currentReachabilityStatus == .NotReachable {
//      self.needConnectNet()
//      return
//    }
    
    if let navi = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("LaunchNaviViewController") as? LaunchNaviViewController,
    let phoneregister = navi.topViewController as? PhoneRegisterViewController {
      phoneregister.type = type == "Login" ? .Login : .Register
      navi.launchDelegate = self
      
      dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
        
        self.presentViewController(navi, animated: true, completion: nil)
        
      })
    }
  }
  
  @IBAction func LoginAction(sender: UIButton) {
    
    if !WXApi.isWXAppInstalled() {
      let alert = AlertHelper.alert_wechatNotInstalled()
      presentViewController(alert, animated: true, completion: nil)
      return
    }
    
    let authOptions = ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStyleFullScreenPopup, viewDelegate: nil, authManagerViewDelegate: nil);
    
    HUD.launch_Loading()
    ShareSDK.getUserInfoWithType(ShareTypeWeixiSession, authOptions: authOptions) { (result, userInfo, error) -> Void in
      //
      
      if result {
        let userId = userInfo.uid()
        let nickName = userInfo.nickname()
        let profileImage = userInfo.profileImage()
        
        
        var userModel = UserModel();
        userModel.nikename = nickName;
        userModel.iconURL = profileImage;
        userModel.weixin = userId;
        
        let userRequest = UserRequest();
        userRequest.setRegisterDelegate(self);
        userRequest.weixinRegister(userModel);
      }else{
        HUD.dismiss()
        let loginError = NSLocalizedString("CONNECT_IOERROR", comment: "")
        let alert = UIAlertView()
        alert.title = ""
        alert.message = loginError
        alert.addButtonWithTitle("Ok")
        alert.show()
      }
    }
  }
}

extension LoginViewController{
  func requestFailed(resultIndex:RegisterRequestEnum){
    var loginError = NSLocalizedString("LOGIN_ERROR", comment: "");
    switch(resultIndex){
    case .IOERROR:
      loginError = NSLocalizedString("CONNECT_IOERROR", comment: "");
    default:
      loginError = NSLocalizedString("LOGIN_ERROR", comment: "")
    }
    let alertTitle = ""
    let alert = UIAlertView()
    alert.title = alertTitle
    alert.message = loginError
    alert.addButtonWithTitle("Ok")
    alert.show()
  }
  
  func requestSuccess(userModel:UserModel, resultIndex:RegisterRequestEnum){
    saveUserInfo(userModel);
  }
  
  private func saveUserInfo(userInfo:UserModel){
    HUD.dismiss()
    LoginModel.shareInstance.login(userInfo)
  }
}
