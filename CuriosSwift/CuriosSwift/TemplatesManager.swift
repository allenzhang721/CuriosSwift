//
//  TemplatesManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/14/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class TemplatesManager {
  
  static let shareInstance = TemplatesManager()
  
  func getTemplates(themesID: String, start: Int, size: Int, completedBlock: ([TemplateModel]) -> ()) {
    
    let paraString = GET_TEMPLATE_LIST_paras(themesID, start, size)
    
    TemplatesRequest.requestWithComponents(GET_TEMPLATE_LIST, aJsonParameter: paraString) { (json) -> Void in
      
      if let list = json["list"] as? [AnyObject] {
        let aTemplateList = MTLJSONAdapter.modelsOfClass(TemplateModel.self, fromJSONArray: list, error: nil) as! [TemplateModel]
        completedBlock(aTemplateList)
      }
      
      }.sendRequest()
  }
}