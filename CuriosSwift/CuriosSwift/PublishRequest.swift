//
//  PublishRequest.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/8/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class PublishRequest: BaseRequst {
    
    class func requestWith(userID: String, publishID: String, publishURL:String, publisherIconURL: String! = "",publishTitle: String! = "", publishDesc: String! = "", publishSnapshots: [[String : String]], aResult: Result) -> BaseRequst {
        
        var dic = [String : AnyObject]()
        dic["userID"] = userID
        dic["publishID"] = publishID
        dic["publishURL"] = publishURL
        dic["publisherIconURL"] = publisherIconURL
        dic["publishTitle"] = publishTitle
        dic["publishDesc"] = publishDesc
        dic["publishSnapshots"] = publishSnapshots
        
        let data = NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions(0), error: nil)
        let jsonParameter = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
        
        return requestWithComponents(["publish/publishFile"], aJsonParameter: jsonParameter, aResult: aResult)
    }
}