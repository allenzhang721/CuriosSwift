//
//  UUIDGenerator.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/23/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

func UniqueIDString() -> String {
    
    var error:NSError?
    
    let regex = NSRegularExpression(pattern: "-", options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
    let uuid = NSProcessInfo.processInfo().globallyUniqueString
    let result = regex?.stringByReplacingMatchesInString(uuid, options:NSMatchingOptions(0), range: NSMakeRange(0,uuid.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)), withTemplate: "")
    
    return result!
    
}