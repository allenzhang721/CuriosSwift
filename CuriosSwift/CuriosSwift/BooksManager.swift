//
//  BooksManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/25/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

//class BooksManager: bookMangerInterface {
//    
//    let userManger: UsersManager
//    var bookList: [String]
//    
//    init(aUserManager: UsersManager, aBookList: [String]) {
//        userManger = aUserManager
//        bookList = aBookList
//    }
//
//    func loadBookList() {
//        
//        let fileManager = NSFileManager.defaultManager()
//        let userID = userManger.getUserID()
//        let documentPath = defaultPath.documentDirectoryURL
//        let userDirPath = documentPath?.URLByAppendingPathComponent(userID)
//    }
    
//    func getBookPath(aBookID: String) -> String {
//        
//        let fileManager = NSFileManager.defaultManager()
//        let userID = userManger.getUserID()
//        let documentPath = defaultPath.documentDirectoryURL
//        let bookDirectoryPath = documentPath!.URLByAppendingPathComponent(userID).URLByAppendingPathComponent(aBookID).absoluteString
//        return bookDirectoryPath!
//    }
//}



// MARK: - IBook
// MARK: - 
//extension BooksManager {
//    
//    func createBook(aBookID: String) -> Bool {
//        let fileManager = NSFileManager.defaultManager()
//        let bookDirectoryPath = getBookPath(aBookID)
//        let error = NSErrorPointer()
//        if fileManager.createDirectoryAtPath(bookDirectoryPath, withIntermediateDirectories: false, attributes: nil, error: error) {
//            let imagesDir = Constants.bookImageDirName
//            let pagesDir = Constants.bookPagesDirName
//            let imagesPath = bookDirectoryPath.stringByAppendingPathComponent(imagesDir)
//            let pagesPath = bookDirectoryPath.stringByAppendingPathComponent(pagesDir)
//            if fileManager.createDirectoryAtPath(imagesPath, withIntermediateDirectories: true, attributes: nil, error: nil) && fileManager.createDirectoryAtPath(pagesPath, withIntermediateDirectories: true, attributes: nil, error: nil) {
//                
//                let bookModel = BookModel()
//                bookModel.Id = aBookID
//                bookModel.filePath = bookDirectoryPath
//                bookModel.saveBookInfo()
//                
//                return true
//            } else {
//                fileManager.removeItemAtPath(bookDirectoryPath, error: nil)
//                return false
//            }
//            
//        } else {
//            
//            return false
//        }
//    }
//    
//    
//    func deleteBook(abookID: String) -> Bool {
//        
//        
//    }
//}

