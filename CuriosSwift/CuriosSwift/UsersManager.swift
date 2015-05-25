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
    
    static let shareInstance = UsersManager(aUser: UserModel())
    
    var user: UserModel!
    var bookList = [BookModel]()
    
    init(aUser: UserModel) {
        user = aUser
    }
    
    func setUser(aUser: UserModel) {
        user = aUser
        
        if existUserDirectory() {
            reloadBookList()
        } else {
            createUserDirectory()
            reloadBookList()
        }
    }
    
    func reloadBookList() {
        
        bookList.removeAll(keepCapacity: false)
        
        if existUserDirectory() {
            
            let fileManager = NSFileManager.defaultManager()
            let booksDir = getBooksDirectory()
            let booklistPath = getbooklistPath()
            let booklistData = NSData.dataWithContentsOfMappedFile(booklistPath) as! NSData
            let bookArray = NSJSONSerialization.JSONObjectWithData(booklistData, options: NSJSONReadingOptions(0), error: nil) as! [String]
            
            for bookID in bookArray {
                
                let bookDir = booksDir.stringByAppendingPathComponent(bookID)
                if fileManager.fileExistsAtPath(bookDir) {
                    let bookjsonPath = bookDir.stringByAppendingPathComponent(Constants.defaultWords.bookJsonName + "." + Constants.defaultWords.bookJsonType)
                    let bookjsonData = NSData.dataWithContentsOfMappedFile(bookjsonPath) as! NSData
                    let bookjson: AnyObject? = NSJSONSerialization.JSONObjectWithData(bookjsonData, options: NSJSONReadingOptions(0), error: nil)
                    let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: bookjson as! [NSObject : AnyObject], error: nil) as! BookModel
                    book.filePath = bookDir
                    
                    bookList.append(book)
                }
            }
            
        } else {
            assert(false, "load book list is fail, user dir not exist.")
        }
    }
    
    func saveBookList() {
        
        var bookIDArray = [String]()
        for bookModel in bookList {
            let bookId = bookModel.Id
            bookIDArray.append(bookId)
        }
        let booklistpath = getbooklistPath()
        let aBooklist = bookIDArray as NSArray
        aBooklist.writeToFile(booklistpath, atomically: true)
    }
}

// MARK: - Iuser
// MARK: -

extension UsersManager {
    
    func getUserID() -> String {
        
        return user.userID
    }
    
    func existUserDirectory() -> Bool {
        
        let userDirPath = getUserDirectory()
        return NSFileManager.defaultManager().fileExistsAtPath(userDirPath)
    }
    
    func createUserDirectory() -> Bool {
        
        if existUserDirectory() {
            return false
        } else {
            let userDirPath = getUserDirectory()
            if NSFileManager.defaultManager().createDirectoryAtPath(userDirPath, withIntermediateDirectories: false, attributes: nil, error: nil) {
                
                let booksPath = userDirPath.stringByAppendingPathComponent(Constants.defaultWords.userBooksDirName)
                
                if NSFileManager.defaultManager().createDirectoryAtPath(booksPath, withIntermediateDirectories: false, attributes: nil, error: nil) {
                    
                    let booklistPath = getbooklistPath()
                    let aBooklist = [String]() as NSArray
                    aBooklist.writeToFile(booklistPath, atomically: true)
                    
                    return true
                    
                } else {
                    
                    return false
                }
                
            } else {
                
                assert(false, "Create User Directory is fail.")
                return false
            }
        }
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
    
    private func getUserDirectory() -> String {
        
        let userID = getUserID()
        let documentDir = Constants.defaultPath.documentDirectoryURL
        let userDirPath = documentDir!.URLByAppendingPathComponent(userID).absoluteString!
        return userDirPath
    }
    
    private func getBooksDirectory() -> String {
        
        let userDir = getUserDirectory()
        let booksDirPath = userDir.stringByAppendingPathComponent(Constants.defaultWords.userBooksDirName)
        return booksDirPath
    }
    
    private func getbooklistPath() -> String {
        let booksDir = getBooksDirectory()
        let booklistPath = booksDir.stringByAppendingPathComponent(Constants.defaultWords.userBooksListName)
        return booklistPath
    }
}
