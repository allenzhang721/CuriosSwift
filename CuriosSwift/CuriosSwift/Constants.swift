//
//  Constants.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/25/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

let ranToAngle = CGFloat(180 / M_PI)
let angleToRan = CGFloat(M_PI / 180)

// constant file name
let login_ = "login"
let main_json = "main.json"
let bookList_ = "bookList"
let templateList_ = "Templates"
let admin_ = "Admin"

// path name
let users = "Users"
let templates = "Templates"
let books = "Books"
let images = "images"
let pages = "Pages"


// colors
let defaultBlack = SWColor(hexString: "#2E333E")

struct Constants {
    
    struct defaultPath {
        static let temporaryDirectoryURL = FileSaveManager.applicationTemporaryDirectory()
        static let documentDirectoryURL = FileSaveManager.applicationDirectory(.DocumentDirectory)
    }
    
    struct defaultWords {
        
        static let defaultTeplateDirName = "Templates"
        static let loginFileName = "LoginFile"
        static let publicTemplateDirName = "Templates"
        static let publicTemplateFileName = "Templates"
        static let usersDirName = "Users"
        static let bookJsonName = "main"
        static let userBooksDirName = "Books"    // user's draft book dir
        static let userBooksListName = "bookList" // user's book list file
        static let userTemplatesName = "templatesList" // user's template list file
        static let userTemplateDirName = "Templates" // user's daraft template dir
        static let bookImageDirName = "images"  // book images dir
        static let bookPagesDirName = "Pages"       // pages dir
        static let bookJsonType = "json"
    }
}

// MARK: - FileSaveManager
// MARK: -
private struct FileSaveManager {
    
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