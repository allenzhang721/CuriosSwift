//
//  Register.swift
//  CuriosSwift
//
//  Created by Emiaostein on 8/18/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

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
  