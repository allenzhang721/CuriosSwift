//
//  ImageContentModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Kingfisher

let Host = ""

class ImageContentModel: ComponentModel, IFile {
  
  typealias UpdateImageHandler = (UIImage?) -> ()
  typealias GenerateImageHandler = (UIImage?) -> ()
  
  private var updateImageHandler: UpdateImageHandler?
  private var generateImageHandler: UpdateImageHandler?
  
  func updateImageHandler(updateHandler:UpdateImageHandler) {
    updateImageHandler = updateHandler
  }
  
  func generateImage(imageBlock: GenerateImageHandler) {
    
    let imageSourceType: String = attributes["ImageSourceType"] as! String  // Relative or Absulte
    let imagePath: String = attributes["ImagePath"] as! String // /image/aa.jpg || http://.../bb.jpg
    
    let imageURL: NSURL = {
      if imageSourceType == "Relative" {
        let absolutePath = Host.stringByAppendingPathComponent(imagePath)
        return NSURL(string: absolutePath)!
      } else {
        return NSURL(string: imagePath)!
      }
    }()
    
    KingfisherManager.sharedManager.retrieveImageWithURL(imageURL, optionsInfo: .None, progressBlock: nil) {[unowned self] (image, error, cacheType, imageURL) -> () in
      
      if error != nil {
        println(error)
      } else {
        imageBlock(image)
      }
    }
  }
  
  func updateImage(image: UIImage) {
    
    let imageID = UniqueIDStringWithCount(count: 8)
    let imagePath = "/images/\(imageID).jpg"
    
    attributes["ImageSourceType"] = "Relative" // relative or absulte
    attributes["ImagePath"] = imagePath // /image/aa.jpg || http://.../bb.jpg
    
    let absolutePath = Host.stringByAppendingPathComponent(imagePath)
    KingfisherManager.sharedManager.cache.storeImage(image, forKey: key)
    
    updateImageHandler?(image)
  }

  var imageURL: String {
    get {
      if let relativeImagePath = attributes["ImagePath"] as? String,  // "/image/name.jpg"
         let string = delegate?.fileGetSuperPath(self).stringByAppendingPathComponent(relativeImagePath) {
        return string
      } else {
        assert(false, "ImageCOntentModel not set Delegate ")
        return ""
      }
    }
  }
  
  var key: String {
    
    let imageSourceType: String = attributes["ImageSourceType"] as! String  // relative or Absolute
    let imagePath: String = attributes["ImagePath"] as! String // /image/aa.jpg || http://.../bb.jpg
    
    let imageURL: NSURL = {
      if imageSourceType == "Relative" {
        let absolutePath = Host.stringByAppendingPathComponent(imagePath)
        return NSURL(string: absolutePath)!
      } else {
        return NSURL(string: imagePath)!
      }
      }()
    
    return imageURL.path!
    
  }
  
  override func getResourseData() -> NSData? {
    
    println(" Image Data")
    return nil
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