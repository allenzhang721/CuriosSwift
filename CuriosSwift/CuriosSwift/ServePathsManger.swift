//
//  ServePathsManger.swift
//  CuriosSwift
//
//  Created by Emiaostein on 8/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

private let defaultManagerInstance = ServePathsManger()
private let imageFilePathKey = "com.botai.Curios.constant.keys.imageFIlePath"
private let publishFilePathKey = "com.botai.Curios.constant.keys.publishFilePath"
private let templateFilePathKey = "com.botai.Curios.constant.keys.templateFilePath"

public class ServePathsManger {
  
  private let manager = ServePathsManger()
  
  public class var shareManger: ServePathsManger {
    return defaultManagerInstance
  }
  
  public class var imagePath: String? {
    return NSUserDefaults.standardUserDefaults().stringForKey(imageFilePathKey)
  }
  
  public class var publishFilePath: String? {
    return NSUserDefaults.standardUserDefaults().stringForKey(publishFilePathKey)
  }
  
  public class var templateFilePath: String? {
    return NSUserDefaults.standardUserDefaults().stringForKey(templateFilePathKey)
  }
  
  class func getServePaths(compeleted:((Bool) -> ())?) {
    
    FilePathsRequest.requestWithComponents(FILEPATH_ALL, aJsonParameter: nil) { (json) -> Void in
      
      if let type = json["resultType"] as? String where type == "success" {
        
        if let value = json["imageFilePath"] as? String {
          
          NSUserDefaults.standardUserDefaults().setObject(value, forKey: imageFilePathKey)
        }
        
        if let value = json["publishFilePath"] as? String {
          
          NSUserDefaults.standardUserDefaults().setObject(value, forKey: publishFilePathKey)
        }
        
        if let value = json["templateFilePath"] as? String {
          
          NSUserDefaults.standardUserDefaults().setObject(value, forKey: templateFilePathKey)
          
        }
      }
      compeleted?(true)
    }.sendRequest()
  }
}