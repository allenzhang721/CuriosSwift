//
//  LoginRequest.swift
//  Curios
//
//  Created by allen on 15/6/10.
//  Copyright (c) 2015年 botai. All rights reserved.
//

import UIKit
import Mantle

enum LoginRequestEnum: Int {
    case SUCCESS = 0, PASSWORDERROR = 1, PASSWORDNULL = 2, DATAERROR=8, DATENULL=9, IOERROR = 10
}

enum RegisterRequestEnum: Int{
    case SUCCESS = 0, SAMEPHONE = 1, SAMEEMAIL = 2, SAMEWEIXIN=3, SAMEWEIBO=4, REGISTERNULL=5, SAMEUUID=6, DATAERROR=8, DATENULL=9, IOERROR = 10
}

enum UserReuqestEnum: Int{
    case LOGIN = 0, REGISTER = 1
}

class UserRequest :NSObject{
    
    internal weak var loginDelegate: ILoginDelegate?
    
    internal weak var registerDelegate: IRegisterDelegate?
    
    var type = UserReuqestEnum.LOGIN;
    
    func setLoginDelegate(aDelegate: ILoginDelegate) {
        loginDelegate = aDelegate
    }
    func cancelLoginDelegate() {
        loginDelegate = nil
    }
    
    func setRegisterDelegate(aDelegate: IRegisterDelegate){
        registerDelegate = aDelegate;
    }
    func cancelRegisterDelegate(){
        registerDelegate = nil;
    }
    
    
    func login(userModel:UserModel){
        
    }
    
    func weixinLogin(userModel:UserModel){
        
    }
    
    func weixinRegister(userModel:UserModel){
        type = .REGISTER
        if userModel.weixin == "" {
            if let aDelegate = registerDelegate {
                aDelegate.requestFailed(RegisterRequestEnum.REGISTERNULL);
            }
        }else{
            registerAction(["user","weixinRegister"], userModel: userModel);
        }
    }
    
    func registerAction(aRequestComponents: [String], userModel:UserModel){
        let user = userModel
        let userDic = MTLJSONAdapter.JSONDictionaryFromModel(user, error: nil)
        let jsondata = NSJSONSerialization.dataWithJSONObject(userDic, options: NSJSONWritingOptions(0), error: nil)
        let jsonString = NSString(data: jsondata!, encoding: NSUTF8StringEncoding) as! String
        let request =  BaseRequst.requestWithComponents(aRequestComponents, aJsonParameter: jsonString) { dic in
            println(dic)
            let resultTypeStr  = dic["resultType"] as? String
            let resultIndexStr = dic["resultIndex"] as? Int
            var resultMes = RegisterRequestEnum.IOERROR;
            switch resultIndexStr!{
            case 0:
                resultMes = RegisterRequestEnum.SUCCESS
            case 1:
                resultMes = RegisterRequestEnum.SAMEPHONE
            case 2:
                resultMes = RegisterRequestEnum.SAMEEMAIL
            case 3:
                resultMes = RegisterRequestEnum.SAMEWEIXIN
            case 4:
                resultMes = RegisterRequestEnum.SAMEWEIBO
            case 5:
                resultMes = RegisterRequestEnum.REGISTERNULL
            case 6:
                resultMes = RegisterRequestEnum.SAMEUUID
            case 8:
                resultMes = RegisterRequestEnum.DATAERROR
            case 9:
                resultMes = RegisterRequestEnum.DATENULL
            default:
                resultMes = RegisterRequestEnum.IOERROR
            }
            if resultTypeStr == "success" {
                var newUser = UserModel()
                newUser.userID = (dic["userID"] as? String)!
                newUser.nikename = (dic["nikeName"] as? String)!
                newUser.descri = (dic["description"] as? String)!
                newUser.iconURL = (dic["iconURL"] as? String)!
                let sex = dic["sex"] as? Int
                newUser.sex = String(stringInterpolationSegment: sex)
                newUser.email = (dic["email"] as? String)!
                newUser.areacode = String(stringInterpolationSegment: dic["areacode"] as? Int)
                newUser.phone = (dic["phone"] as? String)!
                newUser.weixin = (dic["weixin"] as? String)!
                newUser.weibo = (dic["weibo"] as? String)!;
                newUser.countryID = String(stringInterpolationSegment: dic["countryID"] as? Int)
                newUser.provinceID = String(stringInterpolationSegment: dic["provinceID"] as? Int)
                newUser.cityID = String(stringInterpolationSegment: dic["cityID"] as? Int)
                
                if let aDelegate = self.registerDelegate{
                    aDelegate.requestSuccess(newUser, resultIndex: resultMes);
                }
            }else{
                if let aDelegate = self.registerDelegate{
                    aDelegate.requestFailed(resultMes);
                }
            }

        }
        request.setDelegate(self);
        request.sendRequest()
    }
}

extension UserRequest: IRequestDelegate{
    func requestFailed() {
        
    }
    
    func requestSuccess() {
        
    }
    
    func requestIOError(error: NSError) {
        switch type {
        case .LOGIN:
            if let aDelegate = loginDelegate {
                aDelegate.requestFailed(LoginRequestEnum.IOERROR);
            }
        case .REGISTER:
            if let aDelegate = registerDelegate{
                aDelegate.requestFailed(RegisterRequestEnum.IOERROR);
            }
        }
    }
}


protocol ILoginDelegate:NSObjectProtocol{
    func requestFailed(resultIndex:LoginRequestEnum)
    func requestSuccess(userModel:UserModel, resultIndex:LoginRequestEnum)
}

protocol IRegisterDelegate:NSObjectProtocol{
    func requestFailed(resultIndex:RegisterRequestEnum)
    func requestSuccess(userModel:UserModel, resultIndex:RegisterRequestEnum)
}
