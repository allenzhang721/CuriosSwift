//
//  UserManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

//class UserManager: NSObject, IUser {
//   
//    let fileManager = NSFileManager.defaultManager()
//    let defaultUserName = "admin"
//    private let defaultBookListName = "bookList"
//    private var userBookList = [String]()
//    let defaultDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
//    
//    static let shareInstance = UserManager()
//    
//    func existDirectoryWithUserName(name: String) -> Bool {
//
//        let userDirectory = defaultDirectoryPath.stringByAppendingPathComponent(name)
//        return fileManager.fileExistsAtPath(userDirectory)
//    }
//    
//    func CreateUserDirectoryWithUserName(name: String) -> Bool {
//        
//        let userDirectory = defaultDirectoryPath.stringByAppendingPathComponent(name)
//        if fileManager.createDirectoryAtPath(userDirectory, withIntermediateDirectories: false, attributes: nil, error: nil) {
//            let booklistfilePath = defaultUserName.stringByAppendingPathComponent(defaultBookListName)
//            let bl = userBookList as NSArray
//            bl.writeToFile(booklistfilePath, atomically: true)
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func userDirectoryWithUserName(name: String) -> String? {
//        
//        let userDirectory = defaultDirectoryPath.stringByAppendingPathComponent(name)
//        return fileManager.fileExistsAtPath(userDirectory) ? userDirectory : nil
//    }
//    
//    func appendBookWithName(name: String) -> Bool {
//        for bookName in userBookList {
//            if bookName == name {
//                return false
//            }
//        }
//        
//        userBookList.insert(name, atIndex: 0)
//        return true
//    }
//    
//    func bookCount() -> Int {
//        return userBookList.count
//    }
//    
//}
