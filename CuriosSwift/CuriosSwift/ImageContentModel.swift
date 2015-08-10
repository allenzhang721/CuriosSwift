//
//  ImageContentModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Kingfisher

class ImageContentModel: ComponentModel, IFile {
  
  private var HOST: String! {
    
    return ServePathsManger.imagePath!
  }
  
  private var updateImageHandler: ((UIImage?) -> ())?
  private var generateImageHandler: ((UIImage?) -> ())?
  
  var imageWidth: CGFloat? {
    
    get {
      let value = attributes["ImageWidth"] as? CGFloat
      return value
    }
    
    set {
      
      if let anewValue = newValue {
        attributes["ImageWidth"] = anewValue
      }
    }
  }
  
  var imageHeight: CGFloat? {
    
    get {
      let value = attributes["ImageHeight"] as? CGFloat
      return value
    }
    
    set {
      
      if let anewValue = newValue {
        attributes["ImageHeight"] = anewValue
      }
    }
  }
  
  var imageID: String? {
    
    get {
      let string = attributes["ImageID"] as? String
      return string
    }
    
    set {
      attributes["ImageID"] = newValue
    }
  }
  
  var key: String {
    
    get {
      let string = attributes["ImagePath"] as! String
      return HOST.stringByAppendingString(string)
    }
    
    set {
      attributes["ImagePath"] = newValue
    }
  }
  
  func updateImageHandler(updateHandler:((UIImage?) -> ())?) {
    updateImageHandler = updateHandler
  }
  
  func retriveImageSize() -> CGSize? {
    
    if let width = imageWidth,
      let height = imageHeight {
        
        return CGSize(width: width, height: height)
    }
    
    return nil
  }
  
  func generateImage(imageBlock: ((UIImage?) -> ())?) {
    
    let url = NSURL(string: key)!
    
    KingfisherManager.sharedManager.retrieveImageWithURL(url, optionsInfo: .None, progressBlock: nil) {[unowned self] (image, error, cacheType, imageURL) -> () in
      if error != nil {
        println(error)
      } else {
        imageBlock?(image)
      }
    }
  }
  
  func updateImage(image: UIImage, userID: String, PublishID: String) {
    needUpload = true
    
    imageWidth = image.size.width
    imageHeight = image.size.height
    
    KingfisherManager.sharedManager.cache.removeImageForKey(key)
    let aImageID = imageID ?? UniqueIDStringWithCount(count: 8)
    
    if aImageID != imageID {
      editDelegate?.componentModelDidUpdate(self)
      imageID = aImageID
    }
    key = pathByComponents([userID, PublishID, "\(aImageID).jpg"])
    KingfisherManager.sharedManager.cache.storeImage(image, forKey: key)
    
    updateImageHandler?(image)
  }
  
  override func getResourseData(handler: (NSData?, String?) -> ()) {
    
    let aKey = attributes["ImagePath"] as! String
    KingfisherManager.sharedManager.cache.retrieveImageForKey(key, options: KingfisherManager.DefaultOptions) {[unowned self] (image, type) -> () in
      if let aImage = image {
        let data = UIImageJPEGRepresentation(image, 1)
        
        handler(data, aKey)
      } else {
        handler(nil, nil)
      }
    }
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
//    //        let value = imagePath
//    let value = temporaryDirectory("\(iD).jpg").path!
//    
//    FileUplodRequest.uploadFileWithKeyFile([key:value])
    
  }
  
  override func removed() {
    
    KingfisherManager.sharedManager.cache.removeImageForKey(key)
    needUpload = false
    super.removed()
  }
}