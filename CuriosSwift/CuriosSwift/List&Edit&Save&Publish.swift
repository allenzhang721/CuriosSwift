//
//  Edit&Save&Publish.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/14/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation


// MARK: - User Book List
let USER_FILE_LIST = ["publish", "userFileList"]
func USER_FILE_LIST_paras(userID: String, start: Int, size: Int) -> String {
  let data: [String: AnyObject] = [
    "userID":userID,
    "start":start,
    "size":size]
  return dicToJson(data)
}


// MARK: - Add Edit File
let ADD_EDITED_FILE = ["publish", "addEditFile"]
func ADD_EDITED_FILE_paras(
  
  userID: String,
  publishID: String,
  publishResURL: String,
  publisherIconURL: String = "",
  publishTitle: String = "",
  publishDesc: String = "",
  publishSnapshots: [[NSObject:AnyObject]] = [[NSObject:AnyObject]](),
  pageNumber: Int = 0,
  snapshotURL: String = ""
  
  ) -> String {
    
  let data = [
    "userID":userID,
    "publishID":publishID,
    "publishResURL":publishResURL,
    "publisherIconURL":publisherIconURL,
    "publishTitle":publishTitle,
    "publishDesc":publishDesc,
    "publishSnapshots":publishSnapshots,
    "pageNumber":pageNumber,
    "snapshotURL":snapshotURL
    ]
  
  return dicToJson(data as! [String : AnyObject])
}