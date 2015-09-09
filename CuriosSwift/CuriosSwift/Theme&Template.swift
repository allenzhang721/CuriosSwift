//
//  Theme&Template.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/14/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

// MARK: - get templateID
let GET_TEMPLATEID = ["template", "getTemplateID"]

// MARK: - get templateUptoken
let GET_TEMPLATEUPTOKEN = ["upload", "templateUptoken"]
func GET_TEMPLATEUPTOKEN_paras (
  
  key:String) -> String {
    
    let data = ["list":[
      ["key": key]
      ]
    ]
    return dicToJson(data)
}


// MARK: - add template
let ADD_TEMPLATE = ["template", "addTemplate"]
func ADD_TEMPLATE_paras(
  
  authorID: String = "",
  templateID: String,
  templateURL: String,
  templateIconURL: String,
  templateName: String,
  templateDesc: String,
  templatePayType: Int = 0,
  templatePrice: Float = 0.0,
  themeID: String

  ) -> String {
    
    let data = [
      "authorID":authorID,
      "templateID":templateID,
      "templateURL":templateURL,
      "templateIconURL":templateIconURL,
      "templateName":templateName,
      "templateDesc":templateDesc,
      "templatePayType":templatePayType,
      "templatePrice":templatePrice,
      "themeID":themeID
    ]
    
    return dicToJson(data as! [String : AnyObject])
}


// MARK: - Get theme list
let GET_THEME_LIST_ALL = ["template", "themeList"]
func GET_THEME_LIST_ALL_paras(start: Int, size: Int) -> String {
  let data = [
    "start":start,
    "size":size]
  return dicToJson(data)
}

#if MAKER_VERSION
let GET_THEME_LIST = ["template", "themeList"] // 开发版
  #else
let GET_THEME_LIST = ["template", "formalThemeList"]   // 正式版
  #endif
func GET_THEME_LIST_paras(start: Int, size: Int) -> String {
  let data = [
    "start":start,
    "size":size]
  return dicToJson(data)
}


// MARK: - get template list
#if MAKER_VERSION
let GET_TEMPLATE_LIST = ["template","templateList"]  // 开发版
#else
let GET_TEMPLATE_LIST = ["template","formalTemplateList"]   // 正式版
#endif
func GET_TEMPLATE_LIST_paras(themeID: String, start: Int, size: Int) -> String {
  let data: [String: AnyObject] = [
    "themeID":themeID,
    "start":start,
    "size":size]
  return dicToJson(data)
}
