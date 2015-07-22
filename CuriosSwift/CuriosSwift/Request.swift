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
    let com = components.reduce(abaseUrl, combine: { $0.stringByAppendingString("/" + $1) })
    return com
}



class BaseRequst {
  
  let officeDomain = "http://src.curiosapp.com"
    let publicDomain = "http://182.92.150.178/curiosService"
    let testDomain = "http://192.168.1.100:8080/curiosService"
    var baseURL: String {
        
        return publicDomain
    }
    typealias Result = ([String : AnyObject]) -> Void
    let requestComponents: [String]
    let jsonParameter: String?
    let result: Result
    
    internal weak var delegate: IRequestDelegate?
    
    init(aRequestComponents: [String], aJsonParameter: String?, aResult: Result) {
        requestComponents = aRequestComponents
        jsonParameter = aJsonParameter
        result = aResult
    }
    
    class func requestWithComponents(aRequestComponents: [String] , aJsonParameter: String?, aResult: Result) -> BaseRequst {
    
        return BaseRequst(aRequestComponents: aRequestComponents, aJsonParameter: aJsonParameter, aResult: aResult)
    }
    
    func setDelegate(aDelegate: IRequestDelegate) {
        delegate = aDelegate
    }
    
    func cancelDelegate() {
        delegate = nil
    }
    
    func sendRequest() {
        
        var URLParameters: [String : AnyObject]? = nil
        if let ajson = jsonParameter {
            
                URLParameters = [
                "data":ajson
            ]
        }
        
        let url = requstURL(baseURL)(requestComponents)
        
        // Fetch Request
        Alamofire.request(.POST, url, parameters: URLParameters)
            .validate(statusCode: 200..<300)
            .responseJSON{ (request, response, JSON, error) in
                if (error == nil)
                {
                    if let jsondic = JSON as? [String : AnyObject] {
                        self.result(jsondic)
                        if let aDelegate = self.delegate{
                            aDelegate.requestSuccess()
                        }
                    }else{
                        if let aDelegate = self.delegate{
                            aDelegate.requestFailed()
                        }
                    }
                }
                else
                {
                    if let aError = error{
                        if let aDelegate = self.delegate {
                            aDelegate.requestIOError(aError);
                        }
                    }
                    println("HTTP HTTP Request failed: \(error)")
                }
        }
    }
}



protocol IRequestDelegate:NSObjectProtocol{
    func requestSuccess()
    func requestFailed()
    func requestIOError(error:NSError)
}