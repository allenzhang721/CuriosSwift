//
//  UserModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/25/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class UserModel: Model {
    
    var nikename = "Default nike name"
    var userID = ""
    var descri = ""
    var password = ""
    var iconURL = ""
  var sex = 0
    var email = ""
    var phone = ""
    var areacode = ""
    var countryID = 0
    var provinceID = 0
    var cityID = 0
    var weixin = ""
    var weibo = ""
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            "nikename" : "nikename",
            "userID" : "userID",
            "descri" : "description",
            "password" : "password",
            "iconURL" : "iconURL",
            "sex" : "sex",
            "email" : "email",
            "phone" : "phone",
            "areacode" : "areacode",
            "countryID" : "countryID",
            "provinceID" : "provinceID",
            "cityID" : "cityID",
            "weixin" : "weixin",
            "weibo" : "weibo"
        ]
    }
}