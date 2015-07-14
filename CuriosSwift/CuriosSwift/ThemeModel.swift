//
//  ThemeModel.swift
//  
//
//  Created by Emiaostein on 7/14/15.
//
//

import UIKit

class ThemeModel: Model {
  
  var themeDesc = ""
  var themeID = ""
  var themeIconURL = ""
  var themeName = ""
  var themeURL = ""
  
  override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
    
    return [
      "themeDesc" : "themeDesc",
      "themeID" : "themeID",
      "themeIconURL" : "themeIconURL",
      "themeName" : "themeName",
      "themeURL" : "themeURL"
    ]
  }
}
