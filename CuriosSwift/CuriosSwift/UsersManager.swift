//
//  UsersManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/25/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class UsersManager: IUser, IBook {
    
    static let shareInstance = UsersManager()
    
    var user: UserModel! {
        
        didSet {
            if user != nil {
                let fileManager = NSFileManager.defaultManager()
                let userID = user.userID
                let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
                let documentDirURL = NSURL(fileURLWithPath: documentDir, isDirectory: true)
                let userURL = documentDirURL?.URLByAppendingPathComponent(Constants.defaultWords.usersDirName).URLByAppendingPathComponent(userID)
                let userDirURL = documentDirectory(users,userID)
                let userBookDirURL = documentDirectory(users,userID,books)
                // user Dir
                
                if fileManager.createDirectoryAtURL(userDirURL, withIntermediateDirectories: false, attributes: nil, error: nil) {
                    
                    if fileManager.createDirectoryAtURL(userBookDirURL, withIntermediateDirectories: false, attributes: nil, error: nil) {
                        println("create user and Books Dir")
                        // booklist File
                        let bookListFileURL = userBookDirURL.URLByAppendingPathComponent(bookList_)
                        
                        let aBooklist = [BookListModel]()
                        let abookListJson = MTLJSONAdapter.JSONArrayFromModels(aBooklist, error: nil)
                        let abookListdata = NSJSONSerialization.dataWithJSONObject(abookListJson, options: NSJSONWritingOptions(0), error: nil)
                        if abookListdata!.writeToURL(bookListFileURL, atomically: true) {
                        }
                    }
                }
                
                reloadBookListWithUser(userID)
            } else {
                bookList.removeAll(keepCapacity: true)
            }
        }
    }
    var bookList = [BookListModel]()
    
    func reloadBookList() {
        
        if user != nil {
            reloadBookListWithUser(user.userID)
        } else {
            bookList.removeAll(keepCapacity: true)
        }
    }
    
    func saveBookList() {
        
        if user != nil {
            
            let bookListJson = MTLJSONAdapter.JSONArrayFromModels(bookList, error: nil)
            let userId = getUserID()
            let bookListFileURL = documentDirectory(users,userId,books,bookList_)
            
            
            let aBooklistJson = NSJSONSerialization.dataWithJSONObject(bookListJson, options: NSJSONWritingOptions(0), error: nil)
            aBooklistJson!.writeToURL(bookListFileURL, atomically: true)
        }
    }
    
    /*
    
    bookID =
    bookName
    descri =
    date: NS
    iconUrl:
    
    */
    
    func updateBookWith(aBookID: String, aBookName: String, aDescription: String, aDate: NSDate, aIconUrl: NSURL) {
        
        println(" updateID = \(aBookID)")
        var index = 0
        var find = false
        for bookListModel in bookList {
            
            println("bookListModel = \(bookListModel.bookID)")
            if bookListModel.bookID == aBookID {
                bookList.removeAtIndex(index)
                let aBookListModel = BookListModel()
                aBookListModel.bookID = aBookID
                aBookListModel.bookName = aBookName
                aBookListModel.descri = aDescription
                aBookListModel.date = aDate
                aBookListModel.iconUrl = aIconUrl
                bookList.insert(aBookListModel, atIndex: index)
                find = true
                break
            }
            index++
        }
        
        if !find {
            let aBookListModel = BookListModel()
            aBookListModel.bookID = aBookID
            aBookListModel.bookName = aBookName
            aBookListModel.descri = aDescription
            aBookListModel.date = aDate
            aBookListModel.iconUrl = aIconUrl
            bookList.insert(aBookListModel, atIndex: 0)
        }
        
        saveBookList()
    }
    
    func duplicateBookTo(templateId: String, toUrl: NSURL) -> Bool {
        
        let existTemplate = bookList.filter { (templateListModel: BookListModel) -> Bool in
            return templateListModel.bookID == templateId
        }
        
        assert(existTemplate.count > 0, "template not exist")
        
        let userID = getUserID()
        let bookId = templateId
        let originBookURL = documentDirectory(users,userID,books,bookId)
        if NSFileManager.defaultManager().copyItemAtURL(originBookURL, toURL: toUrl, error: nil) {
            // change the new book id
            println("copy book")
            return true
        } else {
            return false
        }
    }
}

// MARK: - Iuser
// MARK: -

extension UsersManager {
    
    func getUserID() -> String {
        
        assert(user != nil, "UsersManger Get user ID fail because user not exist.")
        
        return user.userID
    }
}

// MARK: - IBooks
// MARK: -

extension UsersManager {
    
    func createBook(aBookID: String) -> Bool {
        
        return false
    }
    
    func deleteBook(abookID: String) -> Bool {
        
        return false
    }
}

// MARK: - Private Methods
// MARK: -

extension UsersManager {
    
    private func reloadBookListWithUser(userID: String) {
        

        //book list file
        let bookListFileURL = documentDirectory(users,userID,books,bookList_)
        
        if let booklistData = NSData(contentsOfURL: bookListFileURL, options: NSDataReadingOptions(0), error: nil) {
            
            let bookArray = NSJSONSerialization.JSONObjectWithData(booklistData, options: NSJSONReadingOptions(0), error: nil) as! [AnyObject]
            let aBookList = MTLJSONAdapter.modelsOfClass(BookListModel.self, fromJSONArray: bookArray, error: nil) as! [BookListModel]
            
            bookList = aBookList
        }
        
    }
}
