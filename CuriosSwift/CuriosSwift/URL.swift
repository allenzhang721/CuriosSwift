//
//  URL.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/29/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

private func URL(baseURL: String)(isDirectory: Bool)(_ components: String...) -> NSURL {
    let com = components.reduce("", combine: {$0 + "/" + $1})
    let baseUrl = NSURL(fileURLWithPath: baseURL, isDirectory: isDirectory)
    return NSURL(string: com, relativeToURL: baseUrl)!
}

let documentDirectory = URL(NSSearchPathForDirectoriesInDomains(.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0] as! String)(isDirectory: false)

let temporaryDirectory = URL(NSTemporaryDirectory())(isDirectory: false)

let bundle = URL(NSBundle.mainBundle().resourcePath!)(isDirectory: false)