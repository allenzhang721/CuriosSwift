//
//  BookListModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/27/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class BookListModel: Model {
    
    var publishDesc = ""
    var publishID = ""
    var publishIconURL = ""
    var publishDate: NSDate! = NSDate(timeIntervalSinceNow: 0)
    var publishResURL = ""
    var publishTitle = ""
    var publishURL = ""
   
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            "publishDesc" : "publishDesc",
            "publishID" : "publishID",
            "publishIconURL" : "publishIconURL",
            "publishDate" : "publishDate",
            "publishResURL" : "publishResURL",
          "publishTitle" : "publishTitle",
          "publishURL" : "publishURL"
        ]
    }
    
    // publishDate
    class func publishDateJSONTransformer() -> NSValueTransformer {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let forwardBlock: MTLValueTransformerBlock! = {
            (dateStr: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
            return dateFormatter.dateFromString(dateStr as! String)
        }
        
        let reverseBlock: MTLValueTransformerBlock! = {
            (date: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
            return dateFormatter.stringFromDate(date as! NSDate)
        }
        
        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
    }
    
    class func iconUrlJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName:MTLURLValueTransformerName)!
    }
}
