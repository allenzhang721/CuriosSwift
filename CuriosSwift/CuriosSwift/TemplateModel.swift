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
}
