//
//  BookModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class BookModel: Model, IFile {
    
    @objc enum FlipDirections: Int {
        case ver, hor
    }
    
    @objc  enum FlipTypes: Int {
        case translate3d, bb
    }
    var filePath: String = ""
    var Id = UniqueIDString()
    var width = 640
    var height = 1008
    var title = "New Book"
    var desc = ""
    var flipDirection: FlipDirections = .ver
    var flipType: FlipTypes = .bb
    var background = ""
    var backgroundMusic = ""
    var pagesPath = "/Pages"
    var autherID = ""
    var publishDate: NSDate! = NSDate(timeIntervalSinceNow: 0)
    var pagesInfo: [[String : String]] = [[:]]
    var pageModels: [PageModel] = []
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            "Id" : "ID",
            "width" : "MainWidth",
            "height" : "MainHeight",
            "title" : "MainTitle",
            "desc" : "MainDesc",
            "flipDirection" : "FlipDirection",
            "flipType" : "FlipType",
            "background" : "MainBackground",
            "backgroundMusic" : "MainMusic",
            "pagesPath" : "PagesPath",
            "autherID" : "AutherID",
            "publishDate" : "PublishDate",
            "pagesInfo" : "Pages"
        ]
    }
    
    func insertPageModelsAtIndex(aPageModels: [PageModel], AtIndex index: Int) {
        
        var i = index
        for pageModel in aPageModels {
            pageModels.insert(pageModel, atIndex: i)
            pageModel.delegate = self
            i++
        }
    }
    
    func appendPageModel(aPageModel: PageModel) {
        aPageModel.delegate = self
        pageModels.append(aPageModel)
        
    }
    
    func removePageModelAtIndex(index: Int) {
        let aPageModel = pageModels[index]
        aPageModel.delegate = nil
        pageModels.removeAtIndex(index)
    }
    
    // flipDirection
    class func flipDirectionJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "ver":FlipDirections.ver.rawValue,
            "hor":FlipDirections.hor.rawValue
            ])
    }
    
    // fliptypes
    class func flipTypeJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "translate3d":FlipTypes.translate3d.rawValue,
            "bb":FlipTypes.bb.rawValue
            ])
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
    
    // pageModels
    class func pageModelsJSONTransformer() -> NSValueTransformer {
        
        let forwardBlock: MTLValueTransformerBlock! = {
            (jsonArray: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
            
            //            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
            let something: AnyObject! = MTLJSONAdapter.modelsOfClass(PageModel.self, fromJSONArray: jsonArray as! [PageModel], error: nil)
            return something
        }
        
        let reverseBlock: MTLValueTransformerBlock! = {
            (pages: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
            let something: AnyObject! = MTLJSONAdapter.JSONArrayFromModels(pages as! [PageModel], error: nil)
            return something
        }
        
        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
    }
}

extension BookModel {
    
    func fileGetSuperPath(file: IFile) -> String {
        
        return filePath
    }
}
