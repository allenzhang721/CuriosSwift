//
//  RequestURL.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/13/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

func dicToJson(dic: [String: AnyObject]) -> String {
//  let aesKey = BaseRequst.AESDecrptKey
  let jsonData = NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions(0), error: nil)
  let string = NSString(data: jsonData!, encoding: NSUTF8StringEncoding) as! String
//  let encryptString = AESCrypt.encrypt(string, password: aesKey)
  
  
  return string
}



let getPublishID = ["publish", "getPublishID"] // get a new ID when create a new book
//let addPublishFile = ["publish", "publishFile"] // finish published use this API to record the pubish info and get

//let uploadCompleteURL = ["upload", "uploadComplete"]
//let getPublishToken = ["upload", "publishUptoken"] // upload non-resourse(image) file / data's token
//let getImageToken = ["upload", "imageUptoken"] // upload resourse(image) file / data's token

let GET_PUBLISH_ID = ["publish", "getPublishID"]
let GET_PUBLISH_TOKEN = ["upload", "publishUptoken"]
func GET_PUBLISH_TOKEN_paras (key: String) -> String {
  
  let data = ["list":[
    ["key": key]
    ]
  ]
  return dicToJson(data)
}


let GET_IMAGE_TOKEN = ["upload", "imageUptoken"]
func GET_IMAGE_TOKEN_paras (key: String) -> String {
  
  let data = ["list":[
    ["key": key]
    ]
  ]
  return dicToJson(data)
}