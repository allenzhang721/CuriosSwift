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
    var login = false
    var user = UserModel()
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            "login" : "login",
            "user" : "user"
        ]
    }
    
    func loadInfo() {
        
        let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let documentDirURL = NSURL(fileURLWithPath: documentDir, isDirectory: true)
        let loginFile = NSURL(string: Constants.defaultWords.loginFileName, relativeToURL: documentDirURL)
        if let data = NSData(contentsOfURL: loginFile!, options: NSDataReadingOptions(0), error: nil) {
            let base64json = NSData(data: data)
            let jsondata = NSData(base64EncodedData: base64json, options: NSDataBase64DecodingOptions(0))
            let ajson: [NSObject : AnyObject]! = NSJSONSerialization.JSONObjectWithData(jsondata!, options: NSJSONReadingOptions(0), error: nil) as! [NSObject : AnyObject]!
            let loginModel = MTLJSONAdapter.modelOfClass(LoginModel.self, fromJSONDictionary: ajson, error: nil) as! LoginModel
            LoginModel.shareInstance.login = loginModel.login
            LoginModel.shareInstance.user = loginModel.user
            //        return loginModel
        } else {
            LoginModel.shareInstance.login = false
            LoginModel.shareInstance.user = UserModel()
        }
    }
    
    func save() {
        
        let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let documentDirURL = NSURL(fileURLWithPath: documentDir, isDirectory: true)
        let loginFile = NSURL(string: Constants.defaultWords.loginFileName, relativeToURL: documentDirURL)
        let bookjson = MTLJSONAdapter.JSONDictionaryFromModel(self, error: nil)
        let json = NSJSONSerialization.dataWithJSONObject(bookjson, options: NSJSONWritingOptions(0), error: nil)
        let base64json = json?.base64EncodedDataWithOptions(NSDataBase64EncodingOptions(0))
        base64json?.writeToURL(loginFile!, atomically: true)
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
