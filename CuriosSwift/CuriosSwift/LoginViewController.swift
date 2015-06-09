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

        let authOptions = ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStyleFullScreenPopup, viewDelegate: nil, authManagerViewDelegate: nil);
        
        ShareSDK.getUserInfoWithType(ShareTypeWeixiSession, authOptions: authOptions) { (result, userInfo, error) -> Void in
            //
            if result {
                let userId = userInfo.uid()
                let nickName = userInfo.nickname()
                let profileImage = userInfo.profileImage()
                
                
                var userModel = UserModel();
                userModel.userID = userId;
                userModel.nikename = nickName;
                userModel.iconURL = profileImage;
                userModel.weixin = userId;
                
                self.saveUserInfo(userModel);
            }else{
                
            }
        }
    }
    
    private func saveUserInfo(userInfo:UserModel){
        LoginModel.shareInstance.login(userInfo)
    }
}
