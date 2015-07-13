//
//  TextContentModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Kingfisher

class TextContentModel: ComponentModel {
  
  typealias UpdateAttributeStringHandler = (NSAttributedString) -> ()
  typealias GenerateAttributeStringHandler = (NSAttributedString) -> ()
  
  private var updateAttributeStringHandler: UpdateAttributeStringHandler?
  
  var key: String? {
    
    get {
      return attributes["ImagePath"] as? String
    }
    
    set {
      attributes["ImagePath"] = newValue
    }
  }
  
  
  func updateAttributeStringBlock(handler: UpdateAttributeStringHandler) {
    
    updateAttributeStringHandler = handler
  }
  
  func updateFromDemoAttributeString(attributeString: NSAttributedString) -> CGSize {
    attributes["Text"] = attributeString.string
    let str = generateAttributeString()
     return str.boundingRectWithSize(CGSize(width: CGFloat.max, height: CGFloat.max), options: NSStringDrawingOptions(0), context: nil).size
  }
  
  func getDemoAttributeString() -> NSAttributedString {
    
    let text: String =  attributes["Text"] as! String
    let alignment: String = attributes["TextAligment"] as! String
    let color: String =  attributes["TextColor"] as! String
    let name: String = attributes["FontName"] as! String
    let size: CGFloat = 28
    
    let style = NSMutableParagraphStyle()
    
    switch alignment {
    case "center":
      style.alignment = .Center
    case "left":
      style.alignment = .Left
    case "rigth":
      style.alignment = .Right
    default:
      style.alignment = .Left
    }
    
    let textColor = UIColor(hexString: color)!
    let font = UIFont(name: name, size: size)!
    
    let attribute = [
      NSFontAttributeName: font,
      NSParagraphStyleAttributeName: style,
      NSForegroundColorAttributeName: textColor
    ]
    
    let string = NSAttributedString(string: text, attributes: attribute)
    
    return string
    
  }
  
  func getAttributeString() -> NSAttributedString {
    
    let text: String =  attributes["Text"] as! String
    let alignment: String = attributes["TextAligment"] as! String
    let color: String =  attributes["TextColor"] as! String
    let name: String = attributes["FontName"] as! String
    let size: CGFloat = attributes["FontSize"] as! CGFloat
    
    let style = NSMutableParagraphStyle()
    
    switch alignment {
    case "center":
      style.alignment = .Center
    case "left":
      style.alignment = .Left
    case "rigth":
      style.alignment = .Right
    default:
      style.alignment = .Left
    }
    
    let textColor = UIColor(hexString: color)!
    let font = UIFont(name: name, size: size)!
    
    let attribute = [
      NSFontAttributeName: font,
      NSParagraphStyleAttributeName: style,
      NSForegroundColorAttributeName: textColor
    ]
    
    let string = NSAttributedString(string: text, attributes: attribute)
    
    return string
  }
  
  func generateAttributeString() -> NSAttributedString {

    let string = getAttributeString()
    updateAttributeStringHandler?(string)
    return string
  }
  
  func setText(text: String) -> NSAttributedString {
    
    attributes["Text"] = text
    
    let attributeString = generateAttributeString()
//    updateAttributeStringHandler?(attributeString)
    
    return attributeString
  }
  
  func setTextAlignment(alignment: String) -> NSAttributedString {
    
    attributes["TextAligment"] = alignment
    
    let attributeString = generateAttributeString()
//    updateAttributeStringHandler?(attributeString)
    
    return attributeString
  }
  
  func setTextColor(color: String) -> NSAttributedString {
    
    attributes["TextColor"] = color
    
    let attributeString = generateAttributeString()
//    updateAttributeStringHandler?(attributeString)
    
    return attributeString
  }
  
  func setFontName(name: String) -> NSAttributedString {
    
    attributes["FontName"] = name
    
    let attributeString = generateAttributeString()
//    updateAttributeStringHandler?(attributeString)
    
    return attributeString
    
  }
  
  func setFontSize(size: CGFloat) -> NSAttributedString {
    
    attributes["FontSize"] = size
    
    let attributeString = generateAttributeString()
    updateAttributeStringHandler?(attributeString)
    
    return attributeString
  }
  
  func getFontSize() -> CGFloat {
    
    let fontSize = attributes["FontSize"] as! CGFloat
    return fontSize
  }
  
  func cacheSnapshotImage(image: UIImage, userID: String, PublishID: String) {
    
    removeCacheImage()
    let imageID = UniqueIDStringWithCount(count: 8)
    key = pathByComponents([userID, PublishID, "\(imageID).jpg"])
    KingfisherManager.sharedManager.cache.storeImage(image, forKey: key!)
  }
  
  func removeCacheImage() {
    if let aKey = key {
      KingfisherManager.sharedManager.cache.removeImageForKey(aKey)
    }
  }

  override func getResourseData(handler: (NSData?, String?) -> ()) {
    
//    let aKey = attributes["ImagePath"] as! String
    if let aKey = key {
      KingfisherManager.sharedManager.cache.retrieveImageForKey(aKey, options: KingfisherManager.DefaultOptions) {[unowned self] (image, type) -> () in
        if let aImage = image {
          let data = UIImageJPEGRepresentation(image, 1)
          handler(data, aKey)
        } else {
          handler(nil, nil)
        }
      }
    } else {
      handler(nil, nil)
    }
    
    
  }
  
  override func getResourseDataKey() -> String {
    return ""
  }
  
  override func uploadInfo(userID: String, publishID: String, pageID: String) {
    //        super.uploadInfo(userID, publishID: publishID, pageID: pageID)
    
//    if needUpload {
//      needUpload = false
//    }else {
//      return
//    }
//    
//    let selfPath = attributes["ImagePath"] as! String
//    let key = userID.stringByAppendingPathComponent(publishID).stringByAppendingPathComponent("res").stringByAppendingPathComponent("Pages").stringByAppendingPathComponent(pageID).stringByAppendingPathComponent(selfPath)
//    let valuePath = userID.stringByAppendingPathComponent(publishID).stringByAppendingPathComponent("Pages").stringByAppendingPathComponent(pageID).stringByAppendingPathComponent(selfPath)
//    //        let value = temporaryDirectory(valuePath).path!
//    let value = temporaryDirectory("\(name).jpg").path!
//    
//    FileUplodRequest.uploadFileWithKeyFile([key:value])
//    
//    println("TextimageModel:key:\(key)")
  }
}