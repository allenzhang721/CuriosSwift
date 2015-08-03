//
//  EMDownloadCacheManager.swift
//  EMDownloadCacheManager
//
//  Created by Emiaostein on 7/30/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

public typealias DownloadProgressBlock = ((receivedSize: Int64, totalSize: Int64) -> ())
public typealias CompletionHandler = ((data: NSData?, error: NSError?, cacheType: CacheType, URL: NSURL?) -> ())

/**
*  RetrieveImageTask represents a task of image retrieving process.
*  It contains an async task of getting image from disk and from network.
*/
public class RetrieveDataTask {
  
  var diskRetrieveTask: RetrieveDataDiskTask?
  var downloadTask: RetrieveDataDownloadTask?
  
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

public let BlackCatErrorDomain = "com.emiaostein.BlackCat.Error"


private let instance = BlackCatManager()

/**
*  Main manager class of BlackCat
*/
public class BlackCatManager {
  
  /**
  *	Options to control some downloader and cache behaviors.
  */
  public typealias Options = (forceRefresh: Bool, lowPriority: Bool, cacheMemoryOnly: Bool, queue: dispatch_queue_t!)
  
  /// A preset option tuple with all value set to `false`.
  public static let OptionsNone: Options = {
    return (forceRefresh: false, lowPriority: false, cacheMemoryOnly: false, queue: dispatch_get_main_queue())
    }()
  
  /// The default set of options to be used by the manager to control some downloader and cache behaviors.
  public static var DefaultOptions: Options = OptionsNone
  
  /// Shared manager used by the extensions across BlackCat.
  public class var sharedManager: BlackCatManager {
    return instance
  }
  
  /// Cache used by this manager
  public var cache: DataCache
  
  /// Downloader used by this manager
  public var downloader: DataDownloader
  
  /**
  Default init method
  
  :returns: A BlackCat manager object with default cache and default downloader.
  */
  public init() {
    cache = DataCache.defaultCache
    downloader = DataDownloader.defaultDownloader
  }
  
  /**
  Get an image with URL as the key.
  If BlackCatOptions.None is used as `options`, BlackCat will seek the image in memory and disk first.
  If not found, it will download the image at URL and cache it.
  These default behaviors could be adjusted by passing different options. See `BlackCatOptions` for more.
  
  :param: URL               The image URL.
  :param: optionsInfo       A dictionary could control some behaviors. See `BlackCatOptionsInfo` for more.
  :param: progressBlock     Called every time downloaded data changed. This could be used as a progress UI.
  :param: completionHandler Called when the whole retriving process finished.
  
  :returns: A `RetrieveImageTask` task object. You can use this object to cancel the task.
  */
  public func retrieveDataWithURL(URL: NSURL,
    optionsInfo: BlackCatOptionsInfo?,
    progressBlock: DownloadProgressBlock?,
    completionHandler: CompletionHandler?) -> RetrieveDataTask
  {
    func parseOptionsInfo(optionsInfo: BlackCatOptionsInfo?) -> (Options, DataCache, DataDownloader) {
      let options: Options
      if let optionsInOptionsInfo = optionsInfo?[.Options] as? BlackCatOptions {
        let queue = (optionsInOptionsInfo & .BackgroundCallback) != .None ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) : BlackCatManager.DefaultOptions.queue
        options = (forceRefresh: (optionsInOptionsInfo & .ForceRefresh) != .None,
          lowPriority: (optionsInOptionsInfo & .LowPriority) != .None,
          cacheMemoryOnly: (optionsInOptionsInfo & .CacheMemoryOnly) != .None,
          queue: queue)
      } else {
        options = BlackCatManager.DefaultOptions
      }
      
      let targetCache = optionsInfo?[.TargetCache] as? DataCache ?? self.cache
      let usedDownloader = optionsInfo?[.Downloader] as? DataDownloader ?? self.downloader
      
      return (options, targetCache, usedDownloader)
    }
    
    let task = RetrieveDataTask()
    
    // There is a bug in Swift compiler which prevents to write `let (options, targetCache) = parseOptionsInfo(optionsInfo)`
    // It will cause a compiler error.
    let parsedOptions = parseOptionsInfo(optionsInfo)
    let (options, targetCache, downloader) = (parsedOptions.0, parsedOptions.1, parsedOptions.2)
    
    if let key = URL.absoluteString {
      if options.forceRefresh {
        downloadAndCacheDataWithURL(URL,
          forKey: key,
          retrieveDataTask: task,
          progressBlock: progressBlock,
          completionHandler: completionHandler,
          options: options,
          targetCache: targetCache,
          downloader: downloader)
      } else {
        let diskTaskCompletionHandler: CompletionHandler = { (data, error, cacheType, URL) -> () in
          // Break retain cycle created inside diskTask closure below
          task.diskRetrieveTask = nil
          completionHandler?(data: data, error: error, cacheType: cacheType, URL: URL)
        }
        let diskTask = targetCache.retrieveDataForKey(key, options: options, completionHandler: { (data, cacheType) -> () in
          if data != nil {
            diskTaskCompletionHandler(data: data, error: nil, cacheType:cacheType, URL: URL)
          } else {
            self.downloadAndCacheDataWithURL(URL,
              forKey: key,
              retrieveDataTask: task,
              progressBlock: progressBlock,
              completionHandler: diskTaskCompletionHandler,
              options: options,
              targetCache: targetCache,
              downloader: downloader)
          }
        })
        task.diskRetrieveTask = diskTask
      }
    }
    
    return task
  }
  
  func downloadAndCacheDataWithURL(URL: NSURL,
    forKey key: String,
    retrieveDataTask: RetrieveDataTask,
    progressBlock: DownloadProgressBlock?,
    completionHandler: CompletionHandler?,
    options: Options,
    targetCache: DataCache,
    downloader: DataDownloader)
  {
    downloader.downloadDataWithURL(URL, retrieveImageTask: retrieveDataTask, options: options, progressBlock: { (receivedSize, totalSize) -> () in
      progressBlock?(receivedSize: receivedSize, totalSize: totalSize)
      return
      }) { (aData, error, imageURL) -> () in
        
        if let error = error where error.code == BlackCatError.NotModified.rawValue {
          // Not modified. Try to find the image from cache.
          // (The image should be in cache. It should be ensured by the framework users.)
          targetCache.retrieveDataForKey(key, options: options, completionHandler: { (cacheImage, cacheType) -> () in
            completionHandler?(data: cacheImage, error: nil, cacheType: cacheType, URL: URL)
            
          })
          return
        }
        
        if let data = aData {
          targetCache.storeData(data, forKey: key, toDisk: !options.cacheMemoryOnly, completionHandler: nil)
        }
        
        completionHandler?(data: aData, error: error, cacheType: .None, URL: URL)
    }
  }
}