//
//  URL.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/29/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

func URL(baseURL: String)(isDirectory: Bool)(_ components: String...) -> NSURL {
    let abaseUrl = NSURL(fileURLWithPath: baseURL, isDirectory: isDirectory)
    let com = components.reduce(abaseUrl, combine: { $0!.URLByAppendingPathComponent($1) })
    return com!
}

let documentDirectory = URL(NSSearchPathForDirectoriesInDomains(.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0] as! String)(isDirectory: true)

let cacheDirectory = URL(NSSearchPathForDirectoriesInDomains(.CachesDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0] as! String)(isDirectory: true)

let temporaryDirectory = URL(NSTemporaryDirectory())(isDirectory: true)

let bundle = URL(NSBundle.mainBundle().resourcePath!)(isDirectory: true)