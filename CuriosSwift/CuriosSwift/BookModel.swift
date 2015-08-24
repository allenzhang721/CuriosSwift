//
//  BookModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class BookModel: Model, IFile, PageModelEditDelegate {
  
  @objc enum FlipDirections: Int {
    case ver, hor
  }
  
  @objc  enum FlipTypes: Int {
    case translate3d
  }
  
  var Id                              = ""
  var flipType: FlipTypes             = .translate3d
  var flipLoop                        = "true"
  var publishDate: NSDate!            = NSDate(timeIntervalSinceNow: 0)
  var authorID                        = ""
  var height                          = 1008
  var width                           = 640
  var flipDirection: FlipDirections   = .ver
  var desc                            = ""
  var title                           = "New Book"
  var mainMusic                       = ""
  var mainbackgroundColor             = "255,255,255"
  var mainbackgroundAlpha: CGFloat    = 1.0
  var icon                            = "images/publishIcon.png"
  var publishURL                      = ""
  var pageModels: [PageModel]         = []
  
  var needUpload = false
  var needAddFile = false
  var editedTitle = false
  var pagesInfo: [[String : String]] = [[:]]
  
  
  override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
    
    return [
      "Id"            : "ID",
      "flipType"      : "FlipType",
      "flipLoop"      : "FlipLoop",
      "publishDate"   : "PublishDate",
      "authorID"      : "AuthorID",
      "height"        : "MainHeight",
      "width"         : "MainWidth",
      "flipDirection" : "FlipDirection",
      "desc"          : "MainDesc",
      "title"         : "MainTitle",
      "mainMusic"     : "MainMusic",
      "mainbackgroundColor" : "MainBackgroundColor",
      "mainbackgroundAlpha" : "MainBackgroundAlpha",
      "icon"                : "FileIcon",
      "pageModels"          : "Pages",
      "publishURL"          : "publishURL"
    ]
  }
  
  required init!(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
    super.init(dictionary: dictionaryValue, error: error)
    
    for page in pageModels {
      page.delegate = self
      page.editDelegate = self
    }
  }
  
  override init!() {
    super.init()
  }
  
//  func saveBookInfo() {
//    
//    let bookjson = MTLJSONAdapter.JSONDictionaryFromModel(self, error: nil)
//    let data = NSJSONSerialization.dataWithJSONObject(bookjson, options: NSJSONWritingOptions(0), error: nil)
//    let main = filePath.stringByAppendingPathComponent(Constants.defaultWords.bookJsonName + "." + Constants.defaultWords.bookJsonType)
//    data?.writeToFile(main, atomically: true)
//  }
  
//  func savePagesInfo() {
//    
//    var newPagesInfo = [[String : String]]()
//    for aPageModel in pageModels {
//      
//      let pageId = aPageModel.Id
//      let pageIDKey = "PageID"
//      let pagePathKey = "Path"
//      let PageIndexKey = "Index"
//      let pageIDValue = pageId
//      let pagePathValue = "/" + pageId
//      let PageIndexValue = "/" + pageId + ".json"
//      
//      let aPageInfo = [pageIDKey : pageIDValue, pagePathKey : pagePathValue, PageIndexKey : PageIndexValue]
//      newPagesInfo.append(aPageInfo)
//    }
//    
//    pagesInfo = newPagesInfo
//    
//    let bookpath = filePath
//    let bookJsonPath = bookpath.stringByAppendingPathComponent(Constants.defaultWords.bookJsonName + "." + Constants.defaultWords.bookJsonType)
//    let bookjson = MTLJSONAdapter.JSONDictionaryFromModel(self, error: nil)
//    let data = NSJSONSerialization.dataWithJSONObject(bookjson, options: NSJSONWritingOptions(0), error: nil)
//    data?.writeToFile(bookJsonPath, atomically: true)
//  }
  
//  func paraserPageInfo() {
//    
//    for page in pageModels {
//      
//      page.delegate = self
//    }
//  }
  
  func savePublishURL(url: String) {
    needUpload = true
    needAddFile = true
    publishURL = url
  }
  
  func retrivePublishURL() -> String? {
    return publishURL.isEmpty ? nil : publishURL
  }
  
  func publishURLIsEmpty() -> Bool {
    
    return publishURL.isEmpty
  }
  
  func isDefaultIcon() -> Bool {
    return (icon.isEmpty || icon == "images/publishIcon.png")
  }
  
  func setBookIcon(string: String) {
    needUpload = true
    needAddFile = true
    icon = string
  }
  
  func setBookTitle(string: String) {
    needUpload = true
    needAddFile = true
    editedTitle = true
    title = string
  }
  
  func setBookDescription(string: String) {
    needUpload = true
    needAddFile = true
    editedTitle = true
    desc = string
  }
  
  func isEditedTitle() -> Bool {
    return editedTitle
  }
  
  func resetEditedTitle() {
    editedTitle = false
  }
  
  func isNeedAddFile() -> Bool {
    
    return needAddFile
    
  }
  
  func resetNeedAddFile() {
    needAddFile = false
  }
  
  func isNeedUpload() -> Bool {
    return needUpload
  }
  
  func resetNeedUpload() {
    needUpload = false
  }
  
  func exchangePageModel(fromIndex: Int, toIndex: Int) {
    needUpload = true
    needAddFile = true
    exchange(&pageModels, fromIndex, toIndex)
  }
  
  func insertPageModelsAtIndex(aPageModels: [PageModel], FromIndex index: Int) {
    needUpload = true
    needAddFile = true
    var i = index
    for pageModel in aPageModels {
      pageModels.insert(pageModel, atIndex: i)
      pageModel.delegate = self
      pageModel.editDelegate = self
      i++
    }
  }
  
  func appendPageModel(aPageModel: PageModel) {
    aPageModel.delegate = self
    //        pageModels.append(aPageModel)
    
  }
  
  func removePageModelAtIndex(index: Int) {
    needUpload = true
    needAddFile = true
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
      "translate3d":FlipTypes.translate3d.rawValue
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
  
  // pages
  class func pageModelsJSONTransformer() -> NSValueTransformer {
    
    let forwardBlock: MTLValueTransformerBlock! = {
      (jsonArray: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
      
      //            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
      let something: AnyObject! = MTLJSONAdapter.modelsOfClass(PageModel.self, fromJSONArray: jsonArray as! [PageModel], error: nil)
      return something
    }
    
    let reverseBlock: MTLValueTransformerBlock! = {
      (containers: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
      let something: AnyObject! = MTLJSONAdapter.JSONArrayFromModels(containers as! [PageModel], error: nil)
      return something
    }
    
    return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
  }
}

extension BookModel {
  
  func targetPageModelDidUpdate(model: PageModel) {
    needUpload = true
    needAddFile = true
  }
  
  func fileGetSuperPath(file: IFile) -> String {
    return Id
  }
}
