//
//  TemplateModel.swift
//  
//
//  Created by Emiaostein on 7/14/15.
//
//

import UIKit

class TemplateModel: Model {
  
  var templateDate = ""
  var templateDesc = ""
  var templateID = ""
  var templateIconURL = ""
  var templateName = ""
  var templatePayType = 0
  var templatePrice = 0
  var templateProductID = ""
  var templateURL = ""
  var templatePageJson: [NSObject: AnyObject]?
  
  override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
    
    return [
      "templateDate" : "templateDate",
      "templateDesc" : "templateDesc",
      "templateID" : "templateID",
      "templateIconURL" : "templateIconURL",
      "templateName" : "templateName",
      "templatePayType" : "templatePayType",
      "templatePrice" : "templatePrice",
      "templateProductID" : "templateProductID",
      "templateURL" : "templateURL"
    ]
  }
  
  func retrivePageModel() -> [NSObject: AnyObject]? {
    
    if let json = templatePageJson {
      
      return json
    } else {
      
      let URL = NSURL(string: templateURL)!
      
      BlackCatManager.sharedManager.retrieveDataWithURL(URL, optionsInfo: nil, progressBlock: nil, completionHandler: {[weak self] (data, error, cacheType, URL) -> () in
        if let strongSelf = self {
            if let dic = Dictionary<NSObject, AnyObject>.converFromData(data).0 {
                strongSelf.templatePageJson = dic
            }
        }
        
        
        })
      return nil
    }
  }
}









