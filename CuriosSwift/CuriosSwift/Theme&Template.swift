//
//  Theme&Template.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/14/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation


// MARK: - Get theme list
//let GET_THEME_LIST = ["template", "themeList"]
let GET_THEME_LIST = ["template", "formalThemeList"]
func GET_THEME_LIST_paras(start: Int, size: Int) -> String {
  let data = [
    "start":start,
    "size":size]
  return dicToJson(data)
}


// MARK: - get template list
//let GET_TEMPLATE_LIST = ["template","templateList"]
let GET_TEMPLATE_LIST = ["template","formalTemplateList"]
func GET_TEMPLATE_LIST_paras(themeID: String, start: Int, size: Int) -> String {
  let data: [String: AnyObject] = [
    "themeID":themeID,
    "start":start,
    "size":size]
  return dicToJson(data)
}
