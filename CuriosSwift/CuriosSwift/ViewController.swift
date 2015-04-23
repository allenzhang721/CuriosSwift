//
//  ViewController.swift
//  CuriosSwift
//
//  Created by 星宇陈 on 4/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    struct MainStoryboard {
       static let name = "Main"
        struct viewControllers {
            static let editViewController = "editViewController"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        setupEditViewController()
    }
}

extension ViewController {
    
    private func setupEditViewController() {
        
        let editVC = UIStoryboard(name: MainStoryboard.name, bundle: nil) .instantiateViewControllerWithIdentifier(MainStoryboard.viewControllers.editViewController) as! EditViewController
        
        self.presentViewController(editVC, animated: false, completion: nil)
    }
    
    private func loadbook() {
        
        
    }
}

