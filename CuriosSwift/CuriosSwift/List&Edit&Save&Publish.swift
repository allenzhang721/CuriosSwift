//
//  Edit&Save&Publish.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/14/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

// MARK: - Publish Token


// MARK: - Publish File
let PUBLISH_FILE = ["publish", "publishFile"]
func PUBLISH_FILE_paras(
  
  userID: String,
  publishID: String,
  publishURL: String,
  publisherIconURL: String = "/publishIcon.png",
  publishTitle: String = "new book",
  publishDesc: String = "no description",
  publishSnapshots: [[NSObject:AnyObject]] = [[NSObject:AnyObject]]()
  
  ) -> String {
    
    let data = [
      "userID":userID,
      "publishID":publishID,
      "publishURL":publishURL,
      "publishIconURL":publisherIconURL,
      "publishTitle":publishTitle,
      "publishDesc":publishDesc,
      "publishSnapshots":publishSnapshots
    ]
    
    return dicToJson(data as! [String : AnyObject])
}

// MARK: - delete Publish file 
let DELETE_PUBLISH_FILE = ["publish", "deletePublishFile"]
func DELETE_PUBLISH_FILE_paras(userID: String, publishID: String) -> String {
  let data: [String: AnyObject] = [
    "userID":userID,
    "publishID":publishID]
  return dicToJson(data)
}



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
  publisherIconURL: String = "/publishIcon.png",
  publishTitle: String = "new book",
  publishDesc: String = "no description",
  publishSnapshots: [[NSObject:AnyObject]] = [[NSObject:AnyObject]](),
  pageNumber: Int = 0,
  snapshotURL: String = ""
  
  ) -> String {
    
  let data = [
    "userID":userID,
    "publishID":publishID,
    "publishResURL":publishResURL,
    "publishIconURL":publisherIconURL,
    "publishTitle":publishTitle,
    "publishDesc":publishDesc,
    "publishSnapshots":publishSnapshots,
    "pageNumber":pageNumber,
    "snapshotURL":snapshotURL
    ]
  
  return dicToJson(data as! [String : AnyObject])
}