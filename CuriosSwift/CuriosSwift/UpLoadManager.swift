//
//  UpLoadManager.swift
//  QiniuUpload
//
//  Created by Emiaostein on 6/21/15.
//  Copyright (c) 2015 BoTai Technology. All rights reserved.
//

import Foundation
import Qiniu

final class UpLoadManager {
    
    typealias UploadCompletedBlock = ([String : Bool], Bool) -> Void  //results, completed
    private var canceled = false
    private var completeCount = 0
    private var results = [String : Bool]()
    private let token: String // token
    private let fileKeys: [String : String] // [key : filePath]
    private let completeHandler: UploadCompletedBlock
    private let uploadMananger = QNUploadManager.sharedInstanceWithConfiguration(nil)

    init(aFileKeys: [String : String], aToken: String, aCompleteHandler: UploadCompletedBlock) {
        fileKeys = aFileKeys
        token = aToken
        completeHandler = aCompleteHandler
    }
    
    func cancel() {
        canceled = true
    }
    
    func start() {
        let cancelSignal = {[unowned self] () -> Bool in
            return self.canceled
        }
        
        let defaultOptions = QNUploadOption.defaultOptions()
        let customOptions = QNUploadOption(mime: defaultOptions.mimeType, progressHandler:defaultOptions.progressHandler, params: defaultOptions.params, checkCrc: defaultOptions.checkCrc, cancellationSignal: cancelSignal)
        
        let totalCount = fileKeys.count
        println("total = \(totalCount)")
        for (key, filePath) in fileKeys {
            results[key] = false
            uploadMananger.putFile(filePath, key: key, token: token, complete: { [unowned self] (ResponseInfo, key, response) -> Void in
                if response == nil {
                    
                    println("\(key) = \(ResponseInfo)")
                    
                }
                println("response = \(response)")
                self.results[key] = (response != nil) ? true : false
                self.completeCount++
                println("count = \(self.completeCount)")
                if self.completeCount == totalCount {
                    var results = self.results
                    let successes = results.values.array.reduce(true, combine: { (now, next) -> Bool in
                        return now && next
                    })
                    self.completeHandler(self.results, successes)
                }
                
                }, option: customOptions)
        }
    }
    
    static func getFileKeys(rootURL: NSURL,rootDirectoryName:String, bookId: String, publishID: String, userDirectoryName: String) -> [String : String] {  // get special book upload infomation
        
        let fileManger = NSFileManager.defaultManager()
        var error = NSErrorPointer()
        let mainDirEntries = fileManger.enumeratorAtURL(rootURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsPackageDescendants | NSDirectoryEnumerationOptions.SkipsHiddenFiles) { (url, error) -> Bool in
            println(url.lastPathComponent)
            return true
        }
        
        var dics = [String : String]()
        while let url = mainDirEntries?.nextObject() as? NSURL {
            
            var flag = ObjCBool(false)
            fileManger.fileExistsAtPath(url.path!, isDirectory: &flag)
            if flag.boolValue == false {
                
                let relativePath = url.pathComponents?.reverse()
                var relative = ""
                for path in relativePath as! [String] {
                    
                    if path != rootDirectoryName {
                        relative = ("/" + path + relative)
                    } else {
                        break
                    }
                }
                let key = userDirectoryName + "/" + publishID + relative
                dics[key] = url.path!
            }
        }
        return dics
    }
}
