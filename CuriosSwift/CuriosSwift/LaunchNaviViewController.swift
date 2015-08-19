//
//  LaunchNaviViewController.swift
//  
//
//  Created by Emiaostein on 8/19/15.
//
//

import UIKit

protocol LaunchDelegate: NSObjectProtocol {
  
  func navigationController(controller: LaunchNaviViewController, loginUser user: UserModel)
  
}

class LaunchNaviViewController: UINavigationController {
  
  weak var launchDelegate: LaunchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
