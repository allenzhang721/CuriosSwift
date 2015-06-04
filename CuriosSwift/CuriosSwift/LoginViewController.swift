//
//  LoginViewController.swift
//  Curios
//
//  Created by Emiaostein on 6/2/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var breathView: RippleView!
    override func viewDidLoad() {
        super.viewDidLoad()

        breathView.addBreathAnimation()
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

    @IBAction func LoginAction(sender: UIButton) {
        
        adminLogin()
        
       if let supPar = parentViewController as? ViewController {
            
            supPar.login()
        }
    }
    
    private func adminLogin() {
        
        let loginFileURL = documentDirectory(login_)
        let adminURL = bundle(admin_)
        let json = NSData(contentsOfURL:adminURL)
        
        let base64json = json?.base64EncodedDataWithOptions(NSDataBase64EncodingOptions(0))
        base64json?.writeToURL(loginFileURL, atomically: true)
    }
}
