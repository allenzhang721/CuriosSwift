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
        didload();
        login()
    }
}

extension ViewController {
    
    func didload(){
        TemplatesManager.instanShare.loadTemplates();
        LoginModel.shareInstance.viewController = self;
    }
    
    func login() {
        LoginModel.shareInstance.loadInfo()
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
}



