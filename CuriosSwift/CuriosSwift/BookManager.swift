//
//  DataManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class BookManager: NSObject {
    
    struct constants {
        static let temporaryDirectoryURL = FileSave.applicationTemporaryDirectory()
        static let documentDirectoryURL = FileSave.applicationDirectory(.DocumentDirectory)
    }
    
    class func loadBookFromURL(url: NSURL) -> BookModel? {
        
        
        
        return nil
    }
    
    // TODO:
//    class func checkTemparoryBook() -> BookModel? {
//        
//        let fileManager = NSFileManager.defaultManager().enumeratorAtPath(BookManager.constants.temporaryDirectoryURL?.relativePath!)
//        return []
//    }
//    
    class func copyDemoBook() -> Bool {
        
        let demoBookID = "QWERTASDFGZXCVB"
        let demobookPath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(demoBookID)
        let demoBookURL = NSURL.fileURLWithPath(demobookPath!, isDirectory: true)
        let toBookPath = NSTemporaryDirectory().stringByAppendingPathComponent(demoBookID)
        let toBookURL = NSURL.fileURLWithPath(toBookPath, isDirectory: true)
//        println("demoBookURL = \(demoBookURL)\ntoBookURL = \(toBookURL)")
        NSFileManager.defaultManager().removeItemAtURL(toBookURL!, error: nil)
        return NSFileManager.defaultManager().copyItemAtURL(demoBookURL!, toURL: toBookURL!, error: nil)
    }
    
    class func createBookAtURL(path: NSURL) -> BookModel {
        
        let bookModel = BookModel()
        let bookID = bookModel.Id
        let bookDirectoryPath = path.URLByAppendingPathComponent(bookID).relativePath!
        let url = NSURL.fileURLWithPath(bookDirectoryPath, isDirectory: true)!
        NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: nil)
        let bookDic = MTLJSONAdapter.JSONDictionaryFromModel(bookModel, error: nil)

        let bookjson = NSJSONSerialization.dataWithJSONObject(bookDic, options: NSJSONWritingOptions(0), error: nil)
        let bookJsonPath = bookDirectoryPath.stringByAppendingPathComponent(bookID + ".json")
        let bookjsonUrl = NSURL.fileURLWithPath(bookJsonPath, isDirectory: false)
        bookjson?.writeToURL(bookjsonUrl!, atomically: true)
        
        return BookModel()
    }
    
    class func createPageTo(path: String) -> PageModel {
        
        
        return PageModel()
    }
    
    class func deleteBookWith(path: String) -> Bool {
        
        
        return true
    }
    
    class func deletePageWith(path: String) -> Bool {
        
        return true
    }
   
    
   class func bookWith(path: String) -> BookModel {
    
        return BookModel()
    }
    
    class func pageWith(file: String) -> PageModel {
        
        return PageModel()
    }
}


// MARK: - FileSave
private struct FileSave {
    
     static func saveData(fileData:NSData, directory:NSSearchPathDirectory, path:String, subdirectory:String?) -> Bool
    {
        // Remove unnecessary slash if need
        let newPath = self.stripSlashIfNeeded(path)
        var newSubdirectory:String?
        if let sub = subdirectory {
            newSubdirectory = self.stripSlashIfNeeded(sub)
        }
        // Create generic beginning to file save path
        var savePath = ""
        if let direct = self.applicationDirectory(directory),
            path = direct.path {
                savePath = path + "/"
        }
        
        if (newSubdirectory != nil) {
            savePath.extend(newSubdirectory!)
            self.createSubDirectory(savePath)
            savePath += "/"
        }
        
        // Add requested save path
        savePath += newPath
        

        // Save the file and see if it was successful
        var ok:Bool = NSFileManager.defaultManager().createFileAtPath(savePath,contents:fileData, attributes:nil)
        
        // Return status of file save
        return ok
        
    }
    
     static func saveDataToTemporaryDirectory(fileData:NSData, path:String, subdirectory:String?) -> Bool
    {
        
        // Remove unnecessary slash if need
        let newPath = stripSlashIfNeeded(path)
        var newSubdirectory:String?
        if let sub = subdirectory {
            newSubdirectory = stripSlashIfNeeded(sub)
        }
        
        // Create generic beginning to file save path
        var savePath = ""
        if let direct = self.applicationTemporaryDirectory(),
            path = direct.path {
                savePath = path + "/"
        }
        
        if let sub = newSubdirectory {
            savePath += sub
            createSubDirectory(savePath)
            savePath += "/"
        }
        
        // Add requested save path
        savePath += newPath
        // Save the file and see if it was successful
        let ok:Bool = NSFileManager.defaultManager().createFileAtPath(savePath,contents:fileData, attributes:nil)
        
        // Return status of file save
        return ok
    }
    
    
    // string methods
    
     static func saveString(fileString:String, directory:NSSearchPathDirectory, path:String, subdirectory:String) -> Bool {
        // Remove unnecessary slash if need
        var newPath = self.stripSlashIfNeeded(path)
        var newSubdirectory:String? = self.stripSlashIfNeeded(subdirectory)
        
        // Create generic beginning to file save path
        var savePath = ""
        if let direct = self.applicationDirectory(directory),
            path = direct.path {
                savePath = path + "/"
        }
        
        if let sub = newSubdirectory {
            savePath += sub
            createSubDirectory(savePath)
            savePath += "/"
        }
        
        // Add requested save path
        savePath += newPath
        
        var error:NSError?
        // Save the file and see if it was successful
        var ok:Bool = fileString.writeToFile(savePath, atomically:false, encoding:NSUTF8StringEncoding, error:&error)
        
        if (error != nil) {println(error)}
        
        // Return status of file save
        return ok
        
    }
     static func saveStringToTemporaryDirectory(fileString:String, path:String, subdirectory:String) -> Bool {
        
        var newPath = self.stripSlashIfNeeded(path)
        var newSubdirectory:String? = self.stripSlashIfNeeded(subdirectory)
        
        // Create generic beginning to file save path
        var savePath = ""
        if let direct = self.applicationTemporaryDirectory(),
            path = direct.path {
                savePath = path + "/"
        }
        
        if (newSubdirectory != nil) {
            savePath.extend(newSubdirectory!)
            self.createSubDirectory(savePath)
            savePath += "/"
        }
        
        // Add requested save path
        savePath += newPath
        
        var error:NSError?
        // Save the file and see if it was successful
        var ok:Bool = fileString.writeToFile(savePath, atomically:false, encoding:NSUTF8StringEncoding, error:&error)
        
        if (error != nil) {
            println(error)
        }
        
        // Return status of file save
        return ok;
        
    }
    
    // private methods
    
    //directories
     static func applicationDirectory(directory:NSSearchPathDirectory) -> NSURL? {
        
        var appDirectory:String?
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(directory, NSSearchPathDomainMask.UserDomainMask, true);
        if paths.count > 0 {
            if let pathString = paths[0] as? String {
                appDirectory = pathString
            }
        }
        if let dD = appDirectory {
            return NSURL(string:dD)
        }
        return nil
    }
    
     static func applicationTemporaryDirectory() -> NSURL? {
        
        if let tD = NSTemporaryDirectory() {
            return NSURL(string:tD)
        }
        
        return nil
        
    }
    //pragma mark - strip slashes
    
    private static func stripSlashIfNeeded(stringWithPossibleSlash:String) -> String {
        var stringWithoutSlash:String = stringWithPossibleSlash
        // If the file name contains a slash at the beginning then we remove so that we don't end up with two
        if stringWithPossibleSlash.hasPrefix("/") {
            stringWithoutSlash = stringWithPossibleSlash.substringFromIndex(advance(stringWithoutSlash.startIndex,1))
        }
        // Return the string with no slash at the beginning
        return stringWithoutSlash
    }
    
    private static func createSubDirectory(subdirectoryPath:String) -> Bool {
        var error:NSError?
        var isDir:ObjCBool=false;
        var exists:Bool = NSFileManager.defaultManager().fileExistsAtPath(subdirectoryPath, isDirectory:&isDir)
        if (exists) {
            /* a file of the same name exists, we don't care about this so won't do anything */
            if isDir {
                /* subdirectory already exists, don't create it again */
                return true;
            }
        }
        var success:Bool = NSFileManager.defaultManager().createDirectoryAtPath(subdirectoryPath, withIntermediateDirectories:true, attributes:nil, error:&error)
        
        if (error != nil) { println(error) }
        
        return success;
    }
}
