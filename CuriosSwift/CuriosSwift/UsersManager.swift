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
                // user Dir
                if fileManager.createDirectoryAtURL(userURL!, withIntermediateDirectories: false, attributes: nil, error: nil) {
                    println("create user Dir")
                    // books Dir
                    let userBooksURL = userURL?.URLByAppendingPathComponent(Constants.defaultWords.userBooksDirName)
                    if fileManager.createDirectoryAtURL(userBooksURL!, withIntermediateDirectories: true, attributes: nil, error: nil) {
                        println("create user books Dir")
                    }
                    
                    // booklist File
                    let bookListFileURL = userBooksURL?.URLByAppendingPathComponent(Constants.defaultWords.userBooksListName)
                    
                    let aBooklist = [String]()
                    let abookListjson = NSJSONSerialization.dataWithJSONObject(aBooklist, options: NSJSONWritingOptions(0), error: nil)
                    if abookListjson!.writeToURL(bookListFileURL!, atomically: true) {
                    }
                }
                
                reloadBookListWithUser(userID)
            } else {
                bookList.removeAll(keepCapacity: true)
            }
        }
    }
    var bookList = [BookModel]()
    
    func reloadBookList() {
        
        if user != nil {
            reloadBookListWithUser(user.userID)
        } else {
            bookList.removeAll(keepCapacity: true)
        }
    }
    
    func saveBookList() {
        
        if user != nil {
            
            var bookIDArray = [String]()
            for bookModel in bookList {
                let bookId = bookModel.Id
                bookIDArray.append(bookId)
            }
            
            let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            let documentDirURL = NSURL(fileURLWithPath: documentDir, isDirectory: true)
            let userURL = documentDirURL?.URLByAppendingPathComponent(Constants.defaultWords.usersDirName).URLByAppendingPathComponent(user.userID)
            let userBooksURL = userURL?.URLByAppendingPathComponent(Constants.defaultWords.userBooksDirName)
            let bookListFileURL = userBooksURL?.URLByAppendingPathComponent(Constants.defaultWords.userBooksListName)
            let aBooklistJson = NSJSONSerialization.dataWithJSONObject(bookIDArray, options: NSJSONWritingOptions(0), error: nil)
            aBooklistJson!.writeToURL(bookListFileURL!, atomically: true)
        }
        
        
    }
}

// MARK: - Iuser
// MARK: -

extension UsersManager {
    
    func getUserID() -> String {
        
        assert(user == nil, "UsersManger Get user ID fail because user not exist.")
        
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
        
        let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let documentDirURL = NSURL(fileURLWithPath: documentDir, isDirectory: true)
        let userURL = documentDirURL?.URLByAppendingPathComponent(Constants.defaultWords.usersDirName).URLByAppendingPathComponent(userID)
        let userBooksURL = userURL?.URLByAppendingPathComponent(Constants.defaultWords.userBooksDirName)
        let bookListFileURL = userBooksURL?.URLByAppendingPathComponent(Constants.defaultWords.userBooksListName)
        let booklistData = NSData(contentsOfURL: bookListFileURL!, options: NSDataReadingOptions(0), error: nil)
        
        let bookArray = NSJSONSerialization.JSONObjectWithData(booklistData!, options: NSJSONReadingOptions(0), error: nil) as! [String]
        for bookID in bookArray {
            
            let bookDir = userBooksURL?.URLByAppendingPathComponent(bookID)
            let bookjsonPath = bookDir?.URLByAppendingPathComponent(Constants.defaultWords.bookJsonName + "." + Constants.defaultWords.bookJsonType)
            let bookjsonData = NSData(contentsOfURL: bookjsonPath!, options: NSDataReadingOptions(0), error: nil)
            let bookjson: AnyObject? = NSJSONSerialization.JSONObjectWithData(bookjsonData!, options: NSJSONReadingOptions(0), error: nil)
            let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: bookjson as! [NSObject : AnyObject], error: nil) as! BookModel
            book.filePath = bookDir!.absoluteString!
            
            bookList.append(book)
        }
    }
}
