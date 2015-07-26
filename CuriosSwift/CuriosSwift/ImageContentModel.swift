//
//  ImageContentModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Kingfisher

let Host = "http://7wy3u8.com2.z0.glb.qiniucdn.com/"

class ImageContentModel: ComponentModel, IFile {
  
  private var updateImageHandler: ((UIImage?) -> ())?
  private var generateImageHandler: ((UIImage?) -> ())?
  
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
      return Host.stringByAppendingPathComponent(string)
    }
    
    set {
      attributes["ImagePath"] = newValue
    }
  }
  
  func updateImageHandler(updateHandler:((UIImage?) -> ())?) {
    updateImageHandler = updateHandler
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
    
    KingfisherManager.sharedManager.cache.removeImageForKey(key)
    let aImageID = imageID ?? UniqueIDStringWithCount(count: 8)
    if aImageID != imageID {
      imageID = aImageID
    }
//    let newID = aImageID + UniqueIDStringWithCount(count: 4)
//    let imageID = UniqueIDStringWithCount(count: 8)
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