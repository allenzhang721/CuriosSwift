//
//  EditNavigationViewController.swift
//  
//
//  Created by Emiaostein on 7/19/15.
//
//

import UIKit

protocol EditNavigationViewControllerDelegate: NSObjectProtocol {
  
  func navigationViewController(navigationController: EditNavigationViewController, didGetTemplateJson json: AnyObject)
}

class EditNavigationViewController: UINavigationController {
  
  weak var editDelegate: EditNavigationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
  func begainResponseToLongPress(onScreenPoint: CGPoint) {
    
    if let topVC = topViewController as? EditTemplateViewController {
      
      topVC.begainResponseToLongPress(onScreenPoint)
    }
  }
}
