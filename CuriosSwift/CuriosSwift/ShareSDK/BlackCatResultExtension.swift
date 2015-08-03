//
//  EMBlackCatResultExtension.swift
//  EMDownloadCacheManager
//
//  Created by Emiaostein on 7/31/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol ResultConvertable {
  typealias Result
  static func converFromData(data: NSData!) -> (Result?, NSError?)
}

extension NSData: ResultConvertable {
  
  typealias Result = NSData
  static func converFromData(data: NSData!) -> (Result?, NSError?) {

    var error: NSError? = nil
    if data == nil {
      error = NSError(domain: BlackCatErrorDomain, code: BlackCatError.InvalidURL.rawValue, userInfo: nil)
    }
    return (data, error)
  }
}

extension Dictionary: ResultConvertable {
  typealias Result = Dictionary<NSObject, AnyObject>
  static func converFromData(data: NSData!) -> (Result?, NSError?) {

    if let dic = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? [NSObject: AnyObject] {
      return (dic, nil)
    } else {
      let error = NSError(domain: BlackCatErrorDomain, code: BlackCatError.InvalidURL.rawValue, userInfo: nil)
      return (nil, error)
    }
  }
}

extension Array: ResultConvertable {
  typealias Result = Array<Dictionary<NSObject, AnyObject>>
  static func converFromData(data: NSData!) -> (Result?, NSError?) {
    
    if let arr = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? [[NSObject: AnyObject]] {
      return (arr, nil)
    } else {
      let error = NSError(domain: BlackCatErrorDomain, code: BlackCatError.InvalidURL.rawValue, userInfo: nil)
      return (nil, error)
    }
  }
}
