//
//  UserViewController.swift
//  
//
//  Created by Emiaostein on 7/22/15.
//
//

import UIKit
import Kingfisher

class UserViewController: UIViewController {

  @IBOutlet weak var userNameLabel: UILabel!
//  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var iconImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

      title = localString("USERINFO_TITLE")
      setupView()
    }

  func setupView() {
    
    let backImage = UIImage(named: "Template_Back")
    let backItem = UIBarButtonItem(image: backImage, landscapeImagePhone: nil, style: .Plain, target: self, action: "backAction:")
    //      navigationItem.backBarButtonItem = backItem
    navigationItem.leftBarButtonItem = backItem
    
//    iconImageView.alpha = 0
//    backgroundImageView.alpha = 0
    
    let userName = UsersManager.shareInstance.user.nikename
    userNameLabel.text = userName
    
    let urlString = UsersManager.shareInstance.user.iconURL
    println(urlString)
    let url = NSURL(string: urlString)!
    
    let iconImage = UIImage(named: "placeholder")
    iconImageView.kf_setImageWithURL(url, placeholderImage: iconImage, optionsInfo: nil) {[weak self] (image, error, cacheType, imageURL) -> () in
      
//      self?.iconImageView.image = image
//      self?.backgroundImageView.image = image
      UIView.animateWithDuration(0.3, animations: { () -> Void in
        self?.iconImageView.alpha = 1
//        self?.backgroundImageView.alpha = 1
        
      })
    }
    
    
    
    
  }
  
  func backAction(sender: AnyObject) {
    
    navigationController?.popViewControllerAnimated(true)
  }
  
  @IBAction func CleanCache(sender: AnyObject) {
    
    HUD.user_cleaning()
    KingfisherManager.sharedManager.cache.clearDiskCacheWithCompletionHandler { () -> () in
      
      BlackCatManager.sharedManager.cache.clearDiskCacheWithCompletionHandler({ () -> () in
        
        let time: NSTimeInterval = 1.0
        let delay = dispatch_time(DISPATCH_TIME_NOW,
          Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
          HUD.user_clean_finished()
          
        }
        
      })
    }
  }
  
  @IBAction func logoutAction(sender: UIButton) {
    
    LoginModel.shareInstance.logout();
  }
  
  

}
