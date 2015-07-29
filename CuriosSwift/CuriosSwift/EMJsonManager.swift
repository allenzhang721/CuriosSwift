//
//  EMTemplatesManager.swift
//  FileDownload
//
//  Created by Emiaostein on 7/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

public typealias DownloadProgressBlock = (receivedSize: Int64, totalSize: Int64) -> ()
public typealias CompletionHandler = (Json: AnyObject?, error: NSError?, cacheType: EMCacheType, jsonURL: NSURL?) -> ()


public class RetrieveJsonTask {
  
  var diskRetrieveTask: RetrieveJsonDiskTask?
  var downloadTask: RetrieveJsonDownloadTask?
  
  /**
  Cancel current task. If this task does not begin or already done, do nothing.
  */
  public func cancel() {
    if let diskRetrieveTask = diskRetrieveTask {
      dispatch_block_cancel(diskRetrieveTask)
    }
    
    if let downloadTask = downloadTask {
      downloadTask.cancel()
    }
  }
}

private let instance = EMJsonManager()

public class EMJsonManager {
  
  /// Shared manager used by the extensions across Kingfisher.
  public class var sharedManager: EMJsonManager{
    return instance
  }
  
  /// Cache used by this manager
  public var cache: JsonCache
  
  /// Downloader used by this manager
  public var downloader: JsonDownloader
  
  public init() {
    cache = JsonCache.defaultCache
    downloader = JsonDownloader.defaultDownloader
  }
  
  public func retrieveJsonWithURL(URL: NSURL,
    progressBlock: DownloadProgressBlock?,
    completionHandler: CompletionHandler?) -> RetrieveJsonTask
  {
    let targetCache = self.cache
    let usedDownloader = self.downloader
    let task = RetrieveJsonTask()
    
    if let key = URL.absoluteString {
      let diskTaskCompletionHandler: CompletionHandler = { (json, error, cacheType, jsonURL) -> () in
        task.diskRetrieveTask = nil
        completionHandler?(Json: json, error: error, cacheType: cacheType, jsonURL: jsonURL)
        
      }
      
      let diskTask = targetCache.retrieveJsonForKey(key, completionHandler: { (aJson, cacheType) -> () in
        if aJson != nil {
          diskTaskCompletionHandler(Json: aJson, error: nil, cacheType: cacheType, jsonURL: URL)
        } else {
          
          // download
          self.downloadAndCacheJsonWithURL(URL, forKey: key, retrieveJsonTask: task, progressBlock: progressBlock, completionHandler: completionHandler, targetCache: targetCache, downloader: usedDownloader)
        }
      })
      
      task.diskRetrieveTask = diskTask
      
    }
    
    return task
  }
  
  
  func downloadAndCacheJsonWithURL(URL: NSURL,
    forKey key: String,
    retrieveJsonTask: RetrieveJsonTask,
    progressBlock: DownloadProgressBlock?,
    completionHandler: CompletionHandler?,
    targetCache: JsonCache,
    downloader: JsonDownloader)
  {

    downloader.downloadJsonWithURL(URL, retrieveJsonTask: retrieveJsonTask, progressBlock: { (receivedSize, totalSize) -> () in
      
      progressBlock?(receivedSize: receivedSize, totalSize: totalSize)
      return
      
      
      }, completionHandler: { (aJson, error, jsonURL) -> () in
        
        if let json: AnyObject = aJson {
          targetCache.storeJson(json, length: 100, forKey: key, toDisk: true, completionHandler: { () -> () in
            
            let s = JsonCache.defaultCache.retrieveJsonForKey(key, completionHandler: { (json, cacheType) -> () in
              
               println(cacheType.hashValue)
            })
            
          })
        }
        
        completionHandler?(Json: aJson, error: error, cacheType: .None, jsonURL: URL)
        
    })
    

  }
}