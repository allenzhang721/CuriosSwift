//
//  Register.swift
//  CuriosSwift
//
//  Created by Emiaostein on 8/18/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation




// MARK: - user/changePassword
let USER_CHANGEPASSWORD = ["user", "changePassword"]
func USER_CHANGEPASSWORD_paras (
  userID: String,
  newPassword: String
  
  ) -> String {
    
    let data = [
      "userID": userID,
      "newPassword": newPassword
    ]
    return dicToJson(data)
}


//user/changePasswordByPhone
let USER_CHANGEPASSWORD_PHONE = ["user", "changePasswordByPhone"]
func USER_CHANGEPASSWORD_PHONE_paras (
  phone: String,
  newpassword: String
  
  ) -> String {
    
    let data = [
      "phone": phone,
      "newPassword": newpassword
    ]
    return dicToJson(data)
}


// MARK: - Login
let USER_LOGIN = ["user", "login"]
func USER_LOGIN_paras (
  phone: String,
  password: String
  
  ) -> String {
    
    let data = [
      "phone": phone,
      "password": password
    ]
    return dicToJson(data)
}



// MARK: - update user info
let UPDATE_USER_INFO = ["user","updateUserInfo"]
func UPDATE_USER_INFO_paras(
  userID: String,
  nikeName: String,
  description: String,
  iconURL: String,
  sex: String,
  countryID: String,
  provinceID: String,
  cityID: String
  ) -> String {
    
    let data = [
      "nikeName": nikeName,
      "userID": userID,
      "description": description,
      "iconURL": iconURL,
      "sex": sex,
      "countryID": countryID,
      "provinceID": provinceID,
      "cityID": cityID,
    ]
    return dicToJson(data)
}



// MARK: - Register
let REGISTER = ["user", "register"]
func REGISTER_paras (
  
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
  weibo: String
  ) -> String {
    
    let data = [
      "nikeName": nikeName,
      "userID": userID,
      "description": description,
      "password": password,
      "iconURL": iconURL,
      "sex": sex,
      "email": email,
      "phone": phone,
      "areaCodeID": areaCodeID,
      "countryID": countryID,
      "provinceID": provinceID,
      "cityID": cityID,
      "weixin": weixin,
      "weibo": weibo
    ]
    return dicToJson(data)
}

let REGISTER_PHONE = ["user", "register"]
func REGISTER_PHONE_paras (
  phone: String,
  areacode: String,
  password: String
  ) -> String {
    return REGISTER_paras("", "", "", password, "", "", "", phone, areacode, "", "", "", "", "")
}

let REGISTER_WEIXIN = ["user", "weixinRegister"]
func REGISTER_WEIXIN_paras (
  weixin: String
  ) -> String {
    return REGISTER_paras("", "", "", "", "", "", "", "", "", "", "", "", weixin, "")
}

let REGISTER_WEIBO = ["user", "weiboRegister"]
func REGISTER_WEIBO_paras (
  weibo: String
  ) -> String {
    return REGISTER_paras("", "", "", "", "", "", "", "", "", "", "", "", "", weibo)
}
  