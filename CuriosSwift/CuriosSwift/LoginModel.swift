//
//  LoginModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/27/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class LoginModel: Model {
    
    static let shareInstance = LoginModel()
    var isLogin = false
    var user = UserModel()
    weak var viewController: ViewController?
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            "isLogin" : "isLogin",
            "user" : "user"
        ]
    }
    
    func loadInfo() {
        
        let loginFile = documentDirectory(login_)
        if let data = NSData(contentsOfURL: loginFile, options: NSDataReadingOptions(0), error: nil) {
            let base64json = NSData(data: data)
            let jsondata = NSData(base64EncodedData: base64json, options: NSDataBase64DecodingOptions(0))
            let ajson: [NSObject : AnyObject]! = NSJSONSerialization.JSONObjectWithData(jsondata!, options: NSJSONReadingOptions(0), error: nil) as! [NSObject : AnyObject]!
            let loginModel = MTLJSONAdapter.modelOfClass(LoginModel.self, fromJSONDictionary: ajson, error: nil) as! LoginModel
            LoginModel.shareInstance.isLogin = loginModel.isLogin
            LoginModel.shareInstance.user = loginModel.user
        } else {
            LoginModel.shareInstance.isLogin = false
            LoginModel.shareInstance.user = UserModel()
        }
    }
    
    func save() {
        
        let loginFile = documentDirectory(login_)
        let bookjson = MTLJSONAdapter.JSONDictionaryFromModel(self, error: nil)
        let json = NSJSONSerialization.dataWithJSONObject(bookjson, options: NSJSONWritingOptions(0), error: nil)
        let base64json = json?.base64EncodedDataWithOptions(NSDataBase64EncodingOptions(0))
        base64json?.writeToURL(loginFile, atomically: true)
    }
    
    func login(userInfo:UserModel){
        LoginModel.shareInstance.isLogin = true;
        LoginModel.shareInstance.user  = userInfo;
        save();
        viewController?.loadViewController();
    }
    
    func logout(){
        LoginModel.shareInstance.isLogin = false;
        LoginModel.shareInstance.user  = UserModel();
        save();
        viewController?.loadViewController();
    }
    
    // component
    class func userJSONTransformer() -> NSValueTransformer {
        
        let forwardBlock: MTLValueTransformerBlock! = {
            (jsonDic: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
            
            let something: AnyObject! = MTLJSONAdapter.modelOfClass(UserModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
            return something
        }
        
        let reverseBlock: MTLValueTransformerBlock! = {
            (userModel: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
            
            let something: AnyObject! = MTLJSONAdapter.JSONDictionaryFromModel(userModel as! UserModel, error: error)
            return something
        }
        
        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
    }
}
