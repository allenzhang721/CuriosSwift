//
//  ThemeManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/14/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class ThemesManager {
  
  static let shareInstance = ThemesManager()
  
  private var themeList = [ThemeModel]()
  
  func getThemes(start: Int, size: Int, completedBlock: ([ThemeModel]) -> ()) {
    
    let paraString = GET_THEME_LIST_paras(start, size)
    
    ThemeRequest.requestWithComponents(GET_THEME_LIST, aJsonParameter: paraString) {[unowned self] (json) -> Void in
      
      if let list = json["list"] as? [AnyObject] {
        let aTemplateList = MTLJSONAdapter.modelsOfClass(ThemeModel.self, fromJSONArray: list, error: nil) as! [ThemeModel]
        
        self.appendThemes(aTemplateList)
        completedBlock(aTemplateList)
      }
      
    }.sendRequest()
  }
  
  func getThemes(all:Bool, start: Int, size: Int, completedBlock: ([ThemeModel]) -> ()) {
    
    let paraString = !all ? GET_THEME_LIST_paras(start, size) : GET_THEME_LIST_paras(start, size)
    let requestString = !all ? GET_THEME_LIST : GET_THEME_LIST_ALL
    
    ThemeRequest.requestWithComponents(requestString, aJsonParameter: paraString) {[unowned self] (json) -> Void in
      
      if let list = json["list"] as? [AnyObject] {
        let aTemplateList = MTLJSONAdapter.modelsOfClass(ThemeModel.self, fromJSONArray: list, error: nil) as! [ThemeModel]
        
        completedBlock(aTemplateList)
      }
      
      }.sendRequest()
  }
  
  
  
  
  func getThemeList() -> [ThemeModel] {
    
    return themeList
  }
  
  private func appendThemes(themes: [ThemeModel]) {
    for theme in themes {
      themeList.append(theme)
    }
  }
  
  func appThemes(themes: [ThemeModel], completedBlock: (Bool) -> ()) {
    
  }
  
}