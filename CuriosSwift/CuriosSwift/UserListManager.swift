//
//  UserListManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/14/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class UserListManager {
  
  static let shareInstance = UserListManager()
  
  func getList(userID: String, start: Int, size: Int, completedBlock: ([BookListModel]) -> ()) {
    
    let paraString = USER_FILE_LIST_paras(userID,start, size)
    
    UserEditListRequest.requestWithComponents(USER_FILE_LIST, aJsonParameter: paraString) { (json) -> Void in
      
      if let list = json["list"] as? [AnyObject] {
        let aTemplateList = MTLJSONAdapter.modelsOfClass(BookListModel.self, fromJSONArray: list, error: nil) as! [BookListModel]
        completedBlock(aTemplateList)
      }
      
      }.sendRequest()
  }
  
  func appBooks(books: [BookListModel], completedBlock: (Bool) -> ()) {
    
  }
  
}