//
//  Request.swift
//  Curios
//
//  Created by Emiaostein on 6/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Alamofire

private func requstURL(baseURL: String)(_ components: [String]) -> String {
    let abaseUrl = baseURL
    let com = components.reduce(abaseUrl, combine: { $0.stringByAppendingPathComponent($1) })
    return com
}

class baseRequst {
    
    let baseURL = "http://192.168.1.102:8080/curiosService"
    typealias Result = [String : AnyObject] -> Void
    let requestComponents: [String]
    let jsonParameter: String
    let result: Result
    
    init(aRequestComponents: [String], aJsonParameter: String, aResult: Result) {
        requestComponents = aRequestComponents
        jsonParameter = aJsonParameter
        result = aResult
    }
    
    class func requestWithComponents(aRequestComponents: [String] , aJsonParameter: String, aResult: Result) -> baseRequst {
    
       return baseRequst(aRequestComponents: aRequestComponents, aJsonParameter: aJsonParameter, aResult: aResult)
    }
    
    func sendRequest() {
        
        // Register - Wechat (POST http://192.168.1.102:8080/curiosService/user/weixinRegister)
        
        let URLParameters = [
            "data":jsonParameter,
        ]
        
        debugPrintln(self.requestComponents)
        
        let url = requstURL(baseURL)(requestComponents)
        
        debugPrintln(url)
        
        // Fetch Request
        Alamofire.request(.POST, url, parameters: URLParameters)
            .validate(statusCode: 200..<300)
            .responseJSON{ (request, response, JSON, error) in
                if (error == nil)
                {
                    
                    if let jsondic = JSON as? [String : AnyObject] {
                        
//                        println("HTTP Response Body: \(jsondic)")
                        self.result(jsondic)
                    }
                }
                else
                {
                    println("HTTP HTTP Request failed: \(error)")
                }
        }
    }
}