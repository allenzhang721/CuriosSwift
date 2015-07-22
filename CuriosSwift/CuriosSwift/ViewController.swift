//
//  ViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class ViewController: UIViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
      
      let a = ADD_EDITED_FILE_paras("EMiasteoin", "hahahah", "GGGGGG")
      
      println(a)
      
        didload();
        loadViewController()
        FontsManager.share.registerLocalFonts()
        let string = NSLocalizedString("TEST", comment: "国际化的语言测试")
      
      
//      let main = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent("main.json")
//      let data = NSData(contentsOfURL: main!)
//      
//      let dic :[NSObject : AnyObject] = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(0), error: nil) as! [NSObject : AnyObject]
//      
//      println(dic)
//      
//      let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: dic, error: nil) as! BookModel
//      
//      println(book)
      
    }
}

extension ViewController {
    
    func didload(){
//        TemplatesManager.instanShare.loadTemplates();
        LoginModel.shareInstance.viewController = self;
    }
    
    func loadViewController() {
//        adminLogin()
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



