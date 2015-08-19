//
//  RegisterHelper.swift
//  CuriosSwift
//
//  Created by Emiaostein on 8/18/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class RegisterHelper {
  
  class func register(
    type: String,
    nikeName: String,
    userID: String,
    description: String,
    password: String,
    iconURL: String,
    sex: String,
    email: String,
    phone: String,
    areaCodeID: String,
    countryID: String,
    provinceID: String,
    cityID: String,
    weixin: String,
    weibo: String,
    completed:(Bool, UserModel?) -> ()
    ) {
      
  }
  
  static func userBy(dic: [String: AnyObject]) -> UserModel {
    let newUser = UserModel()
    newUser.userID = (dic["userID"] as? String)!
    newUser.nikename = (dic["nikeName"] as? String)!
    newUser.descri = (dic["description"] as? String)!
    newUser.iconURL = (dic["iconURL"] as? String)!
    newUser.sex = (dic["sex"] as? Int)!
    newUser.email = (dic["email"] as? String)!
    newUser.areacode = (dic["areacode"] as? String)!
    newUser.phone = (dic["phone"] as? String)!
    newUser.weixin = (dic["weixin"] as? String)!
    newUser.weibo = (dic["weibo"] as? String)!
    newUser.countryID = (dic["countryID"] as? Int)!
    newUser.provinceID = (dic["provinceID"] as? Int)!
    newUser.cityID = (dic["cityID"] as? Int)!
    return newUser
  }
  
  
  class func phoneLogin (phone: String, password: String, completed:(Bool, UserModel?) -> ()) {
    
    let paras = USER_LOGIN_paras(phone, password)
    LoginRequest.requestWithComponents(USER_LOGIN, aJsonParameter: paras, aResult: { (dic) -> Void in
      
      if let resultTypeStr  = dic["resultType"] as? String where resultTypeStr == "success" {
        let user = self.userBy(dic)
        completed(true, user)
      } else {
        completed(false, nil)
      }
      
    }).sendRequest()
  }
  
  
  class func phoneRegister (
    phone: String,
    areaCode: String,
    password: String,
    completed:(Bool, Bool, UserModel?) -> ()
    ) {
      let params = REGISTER_PHONE_paras(phone, areaCode, password)
      RegisterPhoneRequest.requestWithComponents(REGISTER_PHONE, aJsonParameter: params) { (dic) -> Void in
        
        if let resultTypeStr  = dic["resultType"] as? String where resultTypeStr == "success" {
          let user = self.userBy(dic)
          if let resultIndex = dic["resultIndex"] as? Int where resultIndex == 1 {
            completed(true, true, user)
          }
          completed(true, false, user)
        } else {
          completed(false, false, nil)
        }
      }.sendRequest()
  }
  
  class func weiXinRegister(
    weixin: String,
    completed:(Bool, UserModel?) -> ()
    ) {
      let params = REGISTER_WEIXIN_paras(weixin)
      RegisterPhoneRequest.requestWithComponents(REGISTER_WEIXIN, aJsonParameter: params) { (dic) -> Void in
        
        if let resultTypeStr  = dic["resultType"] as? String where resultTypeStr == "success" {
          let user = self.userBy(dic)
          completed(true, user)
        } else {
          completed(false, nil)
        }
      }.sendRequest()
  }
  
  class func weiboRegister (
    weibo: String,
    completed:(Bool, UserModel?) -> ()
    ) {
      let params = REGISTER_WEIBO_paras(weibo)
      RegisterPhoneRequest.requestWithComponents(REGISTER_WEIBO, aJsonParameter: params) { (dic) -> Void in
        
        if let resultTypeStr  = dic["resultType"] as? String where resultTypeStr == "success" {
          let user = self.userBy(dic)
          completed(true, user)
        } else {
          completed(false, nil)
        }
      }.sendRequest()
  }
}