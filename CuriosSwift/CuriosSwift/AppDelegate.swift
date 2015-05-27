//
//  AppDelegate.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        createBaseDirectory()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    
    private func createBaseDirectory() {
        let fileManager = NSFileManager.defaultManager()
        let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let documentDirURL = NSURL(fileURLWithPath: documentDir, isDirectory: true)
        let publicTemplateDirURL = NSURL(string: Constants.defaultWords.publicTemplateDirName, relativeToURL: documentDirURL)
        let usersDirURL = NSURL(string: Constants.defaultWords.usersDirName, relativeToURL: documentDirURL)
//        
//        LoginModel.shareInstance.loadInfo()
//        println(LoginModel.shareInstance)
//        
//        LoginModel.shareInstance.login = true
//        
//        
//        let bundlePath = NSBundle.mainBundle().resourcePath
//        let adminPath = bundlePath!.stringByAppendingPathComponent("Admin")
//        let data = NSData.dataWithContentsOfMappedFile(adminPath) as! NSData
//        let admin = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as! [String:AnyObject]
//        
//        if let a = admin["login"] as? Bool where a == true {
//            
//            let json = admin["user"] as? [NSObject : AnyObject]
//            
//            let userModel = MTLJSONAdapter.modelOfClass(UserModel.self, fromJSONDictionary: json , error: nil) as! UserModel
//            LoginModel.shareInstance.user = userModel
//            
//        }
//        
//        
//        LoginModel.shareInstance.save()
//        println(LoginModel.shareInstance)
        
        if fileManager.createDirectoryAtURL(publicTemplateDirURL!, withIntermediateDirectories: false, attributes: nil, error: nil) {
            println("Create PublicTemplate")
        }
        if fileManager.createDirectoryAtURL(usersDirURL!, withIntermediateDirectories: false, attributes: nil, error: nil) {
            println("Create Users")
        }
    }
}

