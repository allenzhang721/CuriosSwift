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
            println(user.userID)
            UsersManager.shareInstance.user = user
        }
    }
}



