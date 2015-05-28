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
    
    var bookID = "sadfasdfasdfasdf"
    var bookName = ""
    var descri = ""
    var date: NSDate! = NSDate(timeIntervalSinceNow: 0)
    var iconUrl: NSURL! = NSURL(fileURLWithPath: "")
   
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            "bookID" : "bookID",
            "bookName" : "bookName",
            "descri" : "descri",
            "date" : "date",
            "iconUrl" : "iconUrl"
        ]
    }
    
    // publishDate
    class func dateJSONTransformer() -> NSValueTransformer {
        
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
