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
        registerShareSDK();
        createBaseDirectory();
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return ShareSDK.handleOpenURL(url, wxDelegate: self);
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self);
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
    
    private func registerShareSDK() {
        
        // TODO: 06.03.2015, http://wiki.mob.com/快速集成指南/ ,“添加实现代码” ,“支持微信所需的相关配置及代码”
        let shareSDKAppID = "7e226fa88de3";
        let weChatAppID = "wx98ddaa7f04ba1e9b";
        let weChatSecretID = "73f38330a03e2f21bf2f72d0fab83cea";
        ShareSDK.registerApp(shareSDKAppID);
        ShareSDK.connectWeChatWithAppId(weChatAppID, appSecret: weChatSecretID, wechatCls: WXApi.self)
        
    }
    
    private func createBaseDirectory() {
        
        let fileManager = NSFileManager.defaultManager();
        let publicTemplateDirURL = documentDirectory(templates);
        let usersDirURL = documentDirectory(users);
        
        // public templates dir
        
        if duplicateTemplatesTo(publicTemplateDirURL) {
            println("copy template");
        }
        if fileManager.createDirectoryAtURL(publicTemplateDirURL, withIntermediateDirectories: false, attributes: nil, error: nil) {
            
            fileManager.removeItemAtURL(publicTemplateDirURL, error: nil);
            println("create template");
            
        }
        
        // users dir
        if fileManager.createDirectoryAtURL(usersDirURL, withIntermediateDirectories: false, attributes: nil, error: nil) {
            println("Create Users Dir");
//            adminLogin()
        }
    }
    
    private func adminLogin() {

        let loginFileURL = documentDirectory(login_);
        let adminURL = bundle(admin_);
        let json = NSData(contentsOfURL:adminURL);
        
        let base64json = json?.base64EncodedDataWithOptions(NSDataBase64EncodingOptions(0));
        base64json?.writeToURL(loginFileURL, atomically: true);
    }
    
    private func duplicateTemplatesTo(toUrl: NSURL) -> Bool {

        let bundleTemplateURL = bundle(templates);
        println(toUrl);
        return NSFileManager.defaultManager().copyItemAtURL(bundleTemplateURL, toURL: toUrl, error: nil);
    }
}

