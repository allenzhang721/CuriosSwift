//
//  ViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle
import ReachabilitySwift

class ViewController: UIViewController {
  
  var hiddenStateBar = false
  let reachability = Reachability.reachabilityForInternetConnection()
  
  @IBOutlet weak var imageView: UIImageView!
  struct MainStoryboard {
    static let name = "Main"
    struct viewControllers {
      static let loginViewController = "LoginViewController"
      static let editViewController = "editViewController"
      static let bookListViewController = "BookListViewController"
      static let bookListNavigationController = "bookListNavigationController"
    }
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return hiddenStateBar
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    didload();
    FontsManager.share.registerLocalFonts()
    self.loadViewController()
  }
  
  override func viewDidAppear(animated: Bool) {
    
    notifier()
  }
  
  func notifier() {
    reachability.whenReachable = { reachability in
      if reachability.isReachableViaWiFi() {
        println("Reachable via WiFi")
      } else {
        println("Reachable via Cellular")
      }
    }
    reachability.whenUnreachable = {[unowned self] reachability in
      self.netbroken()
      println("Not reachable")
    }
    
    reachability.startNotifier()
    
    if reachability.currentReachabilityStatus == .NotReachable {
      self.netbroken()
    }
  }
  
  func netbroken() {
    
    let alert = AlertHelper.alert_internetBroken()
    presentViewController(alert, animated: true, completion: nil)
  }
}

extension ViewController {
  
  func didload(){
    
    LoginModel.shareInstance.viewController = self;
  }
  
  func loadViewController() {
//            adminLogin()
    LoginModel.shareInstance.loadInfo()
    
    println(LoginModel.shareInstance.isLogin)
    
    if LoginModel.shareInstance.isLogin {
      let user = LoginModel.shareInstance.user;
      UsersManager.shareInstance.user = user;
      removeViewController();
      loadBookListViewController();
    } else {
      removeViewController();
      loadLoginViewController()
    }
  }
  
  func loadLoginViewController() {
    
    let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(MainStoryboard.viewControllers.loginViewController) as! LoginViewController
    addChildViewController(loginVC)
    view.addSubview(loginVC.view)
  }
  
  func removeViewController(){
    if childViewControllers.count > 0 {
      
      for childVC in childViewControllers as! [UIViewController] {
        childVC.view.removeFromSuperview();
        childVC.removeFromParentViewController();
      }
    }
  }
  
  func loadBookListViewController() {
    
    let bookListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(MainStoryboard.viewControllers.bookListNavigationController) as! UINavigationController
    let bookvc = bookListVC.topViewController as! BookListViewController
    bookvc.delegate = self
    addChildViewController(bookListVC)
    view.addSubview(bookListVC.view)
  }
  
  func adminLogin() {
    
    let loginFile = documentDirectory(login_)
    let adminUser = bundle(admin_)
    let data = NSData(contentsOfURL: adminUser)?.base64EncodedDataWithOptions(NSDataBase64EncodingOptions(0))
    data?.writeToURL(loginFile, atomically: true)
  }
}

extension ViewController: BookListViewControllerDelegate {
  
  func viewController(controller: UIViewController, needHiddenStateBar hidden: Bool) {
    
    hiddenStateBar = hidden
    setNeedsStatusBarAppearanceUpdate()
  }
}

