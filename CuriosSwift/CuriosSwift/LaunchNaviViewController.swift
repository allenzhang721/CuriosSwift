//
//  LaunchNaviViewController.swift
//  
//
//  Created by Emiaostein on 8/19/15.
//
//

import UIKit
import ReachabilitySwift

protocol LaunchDelegate: NSObjectProtocol {
  
  func navigationController(controller: LaunchNaviViewController, loginUser user: UserModel)
  func navigationControllerDidNetBroken(controller: LaunchNaviViewController)
}

class LaunchNaviViewController: UINavigationController {
  
  let reachability = Reachability.reachabilityForInternetConnection()
  
  weak var launchDelegate: LaunchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    reachability.whenUnreachable = {[weak self] reachability in
      self?.netbroken()
      println("Not reachable")
    }
    
    reachability.startNotifier()
    
    if reachability.currentReachabilityStatus == .NotReachable {
      self.netbroken()
    }
  }
  
  func netbroken() {
    
    launchDelegate?.navigationControllerDidNetBroken(self)
//    let alert = AlertHelper.alert_internetBroken {[weak self] (finished) -> () in
//      self?.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    presentViewController(alert, animated: true, completion: nil)
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
