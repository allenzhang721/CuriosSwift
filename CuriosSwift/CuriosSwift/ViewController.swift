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
            static let editViewController = "editViewController"
            static let bookListViewController = "BookListViewController"
            static let bookListNavigationController = "bookListNavigationController"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        login()
    }
}

extension ViewController {
    
    func login() {
        
        LoginModel.shareInstance.loadInfo()
        if LoginModel.shareInstance.login {
            let user = LoginModel.shareInstance.user
            UsersManager.shareInstance.user = user
            loadBookListViewController()
            TemplatesManager.instanShare.loadTemplates()
        }
    }
    
    func loadBookListViewController() {
        
        let bookListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(MainStoryboard.viewControllers.bookListNavigationController) as! UINavigationController
        addChildViewController(bookListVC)
        view.addSubview(bookListVC.view)
    }
}



