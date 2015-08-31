//
//  ImageHelper.swift
//  imagetype
//
//  Created by Emiaostein on 8/21/15.
//  Copyright (c) 2015 BoTai Technology. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

class ImageHelper {
  
  class func optimizeImageFromLibrary(
    MediaWithInfo info: [NSObject : AnyObject],
    minimumTargetFileSize: Int64 = 1024 * 100,
    targetRect rectSize: CGSize, successBlock: (UIImage, CGSize, Bool) -> (), failBlock:() -> ()) {
      
      debugPrint.p(info)
      
      if let referenceURL = info[UIImagePickerControllerReferenceURL] as? NSURL {
        
        let library = ALAssetsLibrary()
        library.assetForURL(referenceURL, resultBlock: { (asset) -> Void in
          
          let presentation = asset.defaultRepresentation()
          let asize = presentation.size() // file byte size
          let uti = presentation.UTI().pathExtension // extension
          let dimension = presentation.dimensions()
          let image = info[UIImagePickerControllerOriginalImage] as! UIImage
          
          var ispng = true
          
          if asize <= minimumTargetFileSize {
            successBlock(image, dimension, true)
            return
          }
          
          // caculate size
          var optimizeImage: UIImage = image
          var optimizeSize: CGSize = dimension
          if CGRectContainsRect(CGRect(origin: CGPointZero, size: rectSize), CGRect(origin: CGPointZero, size: dimension)) {
            // contain
            
            
          } else {
            
            let w = rectSize.width / dimension.width
            let h = rectSize.height / dimension.height
            // large
            let scale = min(w, h)
            let finalSize = CGSize(width: dimension.width * scale, height: dimension.height * scale)
            
            UIGraphicsBeginImageContext(finalSize)
            image.drawInRect(CGRect(origin: CGPointZero, size: finalSize))
            let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            optimizeImage = scaleImage
            optimizeSize = finalSize
          }
          
          
          if uti != "png" {
            ispng = false
            let data = UIImageJPEGRepresentation(optimizeImage, 0.001)
            optimizeImage = UIImage(data: data)!
          }
          
          successBlock(optimizeImage, optimizeSize, ispng)
          
          println(asize)
          println(dimension)
          
          }, failureBlock: { error in
            
            failBlock()
        })
      } else {
        // image
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let dimension = image.size
        
        // caculate size
        var optimizeImage: UIImage = image
        var optimizeSize: CGSize = dimension
        if CGRectContainsRect(CGRect(origin: CGPointZero, size: rectSize), CGRect(origin: CGPointZero, size: dimension)) {
          // contain
          
          
        } else {
          
          let w = rectSize.width / dimension.width
          let h = rectSize.height / dimension.height
          // large
          let scale = min(w, h)
          let finalSize = CGSize(width: dimension.width * scale, height: dimension.height * scale)
          
          UIGraphicsBeginImageContext(finalSize)
          image.drawInRect(CGRect(origin: CGPointZero, size: finalSize))
          let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
          UIGraphicsEndImageContext()
          
          optimizeImage = scaleImage
          optimizeSize = finalSize
        }
        
        let data = UIImageJPEGRepresentation(optimizeImage, 0.001)
        optimizeImage = UIImage(data: data)!
        
        successBlock(optimizeImage, optimizeSize, false)

      }
      
  } // end
  
}