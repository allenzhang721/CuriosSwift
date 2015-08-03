//
//  EMBlackCatCache.swift
//  EMDownloadCacheManager
//
//  Created by Emiaostein on 7/31/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import UIKit

public let BlackCatDidCleanDiskCacheNotification = "com.emiaostein.BlackCat.BlackCatDidCleanDiskCacheNotification"

/**
Key for array of cleaned hashes in `userInfo` of `BlackCatDidCleanDiskCacheNotification`.
*/
public let BlackCatDiskCacheCleanedHashKey = "com.emiaostein.BlackCat.cleanedHash"

private let defaultCacheName = "default"
private let cacheReverseDNS = "com.emiaostein.BlackCat.DataCache."
private let ioQueueName = "com.emiaostein.BlackCat.DataCache.ioQueue."
private let processQueueName = "com.emiaostein.BlackCat.DataCache.processQueue."

private let defaultCacheInstance = DataCache(name: defaultCacheName)
private let defaultMaxCachePeriodInSecond: NSTimeInterval = 60 * 60 * 24 * 7 //Cache exists for 1 week

public typealias RetrieveDataDiskTask = dispatch_block_t

/**
Cache type of a cached image.

- Memory: The image is cached in memory.
- Disk:   The image is cached in disk.
*/
public enum CacheType {
  case None, Memory, Disk
}

/**
*	`ImageCache` represents both the memory and disk cache system of BlackCat. While a default image cache object will be used if you prefer the extension methods of BlackCat, you can create your own cache object and configure it as your need. You should use an `ImageCache` object to manipulate memory and disk cache for BlackCat.
*/
public class DataCache {
  
  //Memory
  private let memoryCache = NSCache()
  
  /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
  public var maxMemoryCost: UInt = 0 {
    didSet {
      self.memoryCache.totalCostLimit = Int(maxMemoryCost)
    }
  }
  
  //Disk
  private let ioQueue: dispatch_queue_t
  private let diskCachePath: String
  private var fileManager: NSFileManager!
  
  /// The longest time duration of the cache being stored in disk. Default is 1 week.
  public var maxCachePeriodInSecond = defaultMaxCachePeriodInSecond
  
  /// The largest disk size can be taken for the cache. It is the total allocated size of cached files in bytes. Default is 0, which means no limit.
  public var maxDiskCacheSize: UInt = 0
  
  private let processQueue: dispatch_queue_t
  
  /// The default cache.
  public class var defaultCache: DataCache {
    return defaultCacheInstance
  }
  
  /**
  Init method. Passing a name for the cache. It represents a cache folder in the memory and disk.
  
  :param: name Name of the cache. It will be used as the memory cache name and the disk cache folder name. This value should not be an empty string.
  
  :returns: The cache object.
  */
  public init(name: String) {
    
    if name.isEmpty {
      fatalError("[BlackCat] You should specify a name for the cache. A cache with empty name is not permitted.")
    }
    
    let cacheName = cacheReverseDNS + name
    memoryCache.name = cacheName
    
    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    diskCachePath = paths.first!.stringByAppendingPathComponent(cacheName)
    
    ioQueue = dispatch_queue_create(ioQueueName + name, DISPATCH_QUEUE_SERIAL)
    processQueue = dispatch_queue_create(processQueueName + name, DISPATCH_QUEUE_CONCURRENT)
    
    dispatch_sync(ioQueue, { () -> Void in
      self.fileManager = NSFileManager()
    })
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearMemoryCache", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "cleanExpiredDiskCache", name:UIApplicationWillTerminateNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "backgroundCleanExpiredDiskCache", name:UIApplicationDidEnterBackgroundNotification, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

// MARK: - Store & Remove
public extension DataCache {
  /**
  Store an image to cache. It will be saved to both memory and disk.
  It is an async operation, if you need to do something about the stored image, use `-storeImage:forKey:toDisk:completionHandler:`
  instead.
  
  :param: image The image will be stored.
  :param: key   Key for the image.
  */
  public func storeData(data: NSData, forKey key: String) {
    storeData(data, forKey: key, toDisk: true, completionHandler: nil)
  }
  
  /**
  Store an image to cache. It is an async operation.
  
  :param: image             The image will be stored.
  :param: key               Key for the image.
  :param: toDisk            Whether this image should be cached to disk or not. If false, the image will be only cached in memory.
  :param: completionHandler Called when stroe operation completes.
  */
  public func storeData(data: NSData, forKey key: String, toDisk: Bool, completionHandler: (() -> ())?) {
    memoryCache.setObject(data, forKey: key, cost: data.length)
    
    if toDisk {
      dispatch_async(ioQueue, { () -> Void in
//        if let data = data {
          if !self.fileManager.fileExistsAtPath(self.diskCachePath) {
            self.fileManager.createDirectoryAtPath(self.diskCachePath, withIntermediateDirectories: true, attributes: nil, error: nil)
          }
          
          self.fileManager.createFileAtPath(self.cachePathForKey(key), contents: data, attributes: nil)
          
          if let handler = completionHandler {
            dispatch_async(dispatch_get_main_queue()) {
              handler()
            }
          }
          
//        } else {
//          if let handler = completionHandler {
//            dispatch_async(dispatch_get_main_queue()) {
//              handler()
//            }
//          }
//        }
      })
    } else {
      if let handler = completionHandler {
        handler()
      }
    }
  }
  
  /**
  Remove the image for key for the cache. It will be opted out from both memory and disk.
  It is an async operation, if you need to do something about the stored image, use `-removeImageForKey:fromDisk:completionHandler:`
  instead.
  
  :param: key Key for the image.
  */
  public func removeDataForKey(key: String) {
    removeDataForKey(key, fromDisk: true, completionHandler: nil)
  }
  
  /**
  Remove the image for key for the cache. It is an async operation.
  
  :param: key               Key for the image.
  :param: fromDisk          Whether this image should be removed from disk or not. If false, the image will be only removed from memory.
  :param: completionHandler Called when removal operation completes.
  */
  public func removeDataForKey(key: String, fromDisk: Bool, completionHandler: (() -> ())?) {
    memoryCache.removeObjectForKey(key)
    
    if fromDisk {
      dispatch_async(ioQueue, { () -> Void in
        self.fileManager.removeItemAtPath(self.cachePathForKey(key), error: nil)
        if let handler = completionHandler {
          dispatch_async(dispatch_get_main_queue()) {
            handler()
          }
        }
      })
    } else {
      if let handler = completionHandler {
        handler()
      }
    }
  }
  
}

// MARK: - Get data from cache
extension DataCache {
  /**
  Get an image for a key from memory or disk.
  
  :param: key               Key for the image.
  :param: options           Options of retriving image.
  :param: completionHandler Called when getting operation completes with image result and cached type of this image. If there is no such key cached, the image will be `nil`.
  
  :returns: The retriving task.
  */
  public func retrieveDataForKey(key: String, options:BlackCatManager.Options, completionHandler: ((NSData?, CacheType!) -> ())?) -> RetrieveDataDiskTask? {
    // No completion handler. Not start working and early return.
    if (completionHandler == nil) {
      return dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {}
    }
    
    let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
      if let data = self.retrieveDataInMemoryCacheForKey(key) {
          completionHandler?(data, .Memory)
      } else {
        //Begin to load image from disk
        dispatch_async(self.ioQueue, { () -> Void in
          
          if let data = self.retrieveDataInDiskCacheForKey(key) {
              self.storeData(data, forKey: key, toDisk: false, completionHandler: nil)
              dispatch_async(options.queue, { () -> Void in
                if let completionHandler = completionHandler {
                  completionHandler(data, .Disk)
                }
              })
            
          } else {
            // No data found from either memory or disk
            dispatch_async(options.queue, { () -> Void in
              if let completionHandler = completionHandler {
                completionHandler(nil, nil)
              }
            })
          }
        })
      }
    }
    
    dispatch_async(options.queue, block)
    return block
  }
  
  /**
  Get an image for a key from memory.
  
  :param: key Key for the image.
  
  :returns: The image object if it is cached, or `nil` if there is no such key in the cache.
  */
  public func retrieveDataInMemoryCacheForKey(key: String) -> NSData? {
    return memoryCache.objectForKey(key) as? NSData
  }
  
  /**
  Get an image for a key from disk.
  
  :param: key Key for the image.
  :param: scale The scale factor to assume when interpreting the image data.
  
  :returns: The image object if it is cached, or `nil` if there is no such key in the cache.
  */
  public func retrieveDataInDiskCacheForKey(key: String) -> NSData? {
    return diskDataForKey(key)
  }
}

// MARK: - Clear & Clean
extension DataCache {
  /**
  Clear memory cache.
  */
  @objc public func clearMemoryCache() {
    memoryCache.removeAllObjects()
  }
  
  /**
  Clear disk cache. This is an async operation.
  */
  public func clearDiskCache() {
    clearDiskCacheWithCompletionHandler(nil)
  }
  
  /**
  Clear disk cache. This is an async operation.
  
  :param: completionHander Called after the operation completes.
  */
  public func clearDiskCacheWithCompletionHandler(completionHander: (()->())?) {
    dispatch_async(ioQueue, { () -> Void in
      self.fileManager.removeItemAtPath(self.diskCachePath, error: nil)
      self.fileManager.createDirectoryAtPath(self.diskCachePath, withIntermediateDirectories: true, attributes: nil, error: nil)
      
      if let completionHander = completionHander {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completionHander()
        })
      }
    })
  }
  
  /**
  Clean expired disk cache. This is an async operation.
  */
  @objc public func cleanExpiredDiskCache() {
    cleanExpiredDiskCacheWithCompletionHander(nil)
  }
  
  /**
  Clean expired disk cache. This is an async operation.
  
  :param: completionHandler Called after the operation completes.
  */
  public func cleanExpiredDiskCacheWithCompletionHander(completionHandler: (()->())?) {
    // Do things in cocurrent io queue
    dispatch_async(ioQueue, { () -> Void in
      if let diskCacheURL = NSURL(fileURLWithPath: self.diskCachePath) {
        
        let resourceKeys = [NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey]
        let expiredDate = NSDate(timeIntervalSinceNow: -self.maxCachePeriodInSecond)
        var cachedFiles = [NSURL: [NSObject: AnyObject]]()
        var URLsToDelete = [NSURL]()
        
        var diskCacheSize: UInt = 0
        
        if let fileEnumerator = self.fileManager.enumeratorAtURL(diskCacheURL,
          includingPropertiesForKeys: resourceKeys,
          options: NSDirectoryEnumerationOptions.SkipsHiddenFiles,
          errorHandler: nil) {
            
            for fileURL in fileEnumerator.allObjects as! [NSURL] {
              
              if let resourceValues = fileURL.resourceValuesForKeys(resourceKeys, error: nil) {
                // If it is a Directory. Continue to next file URL.
                if let isDirectory = resourceValues[NSURLIsDirectoryKey]?.boolValue {
                  if isDirectory {
                    continue
                  }
                }
                
                // If this file is expired, add it to URLsToDelete
                if let modificationDate = resourceValues[NSURLContentModificationDateKey] as? NSDate {
                  if modificationDate.laterDate(expiredDate) == expiredDate {
                    URLsToDelete.append(fileURL)
                    continue
                  }
                }
                
                if let fileSize = resourceValues[NSURLTotalFileAllocatedSizeKey] as? NSNumber {
                  diskCacheSize += fileSize.unsignedLongValue
                  cachedFiles[fileURL] = resourceValues
                }
              }
              
            }
        }
        
        for fileURL in URLsToDelete {
          self.fileManager.removeItemAtURL(fileURL, error: nil)
        }
        
        if self.maxDiskCacheSize > 0 && diskCacheSize > self.maxDiskCacheSize {
          let targetSize = self.maxDiskCacheSize / 2
          
          // Sort files by last modify date. We want to clean from the oldest files.
          let sortedFiles = cachedFiles.keysSortedByValue({ (resourceValue1, resourceValue2) -> Bool in
            
            if let date1 = resourceValue1[NSURLContentModificationDateKey] as? NSDate {
              if let date2 = resourceValue2[NSURLContentModificationDateKey] as? NSDate {
                return date1.compare(date2) == .OrderedAscending
              }
            }
            // Not valid date information. This should not happen. Just in case.
            return true
          })
          
          for fileURL in sortedFiles {
            if (self.fileManager.removeItemAtURL(fileURL, error: nil)) {
              
              URLsToDelete.append(fileURL)
              
              if let fileSize = cachedFiles[fileURL]?[NSURLTotalFileAllocatedSizeKey] as? NSNumber {
                diskCacheSize -= fileSize.unsignedLongValue
              }
              
              if diskCacheSize < targetSize {
                break
              }
            }
          }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          
          if URLsToDelete.count != 0 {
            let cleanedHashes = URLsToDelete.map({ (url) -> String in
              return url.lastPathComponent!
            })
            
            NSNotificationCenter.defaultCenter().postNotificationName(BlackCatDidCleanDiskCacheNotification, object: self, userInfo: [BlackCatDiskCacheCleanedHashKey: cleanedHashes])
          }
          
          if let completionHandler = completionHandler {
            completionHandler()
          }
        })
        
      } else {
        println("Bad disk cache path. \(self.diskCachePath) is not a valid local directory path.")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if let completionHandler = completionHandler {
            completionHandler()
          }
        })
      }
    })
  }
  
  /**
  Clean expired disk cache when app in background. This is an async operation.
  In most cases, you should not call this method explicitly.
  It will be called automatically when `UIApplicationDidEnterBackgroundNotification` received.
  */
  @objc public func backgroundCleanExpiredDiskCache() {
    
    func endBackgroundTask(inout task: UIBackgroundTaskIdentifier) {
      UIApplication.sharedApplication().endBackgroundTask(task)
      task = UIBackgroundTaskInvalid
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier!
    
    backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
      endBackgroundTask(&backgroundTask!)
    }
    
    cleanExpiredDiskCacheWithCompletionHander { () -> () in
      endBackgroundTask(&backgroundTask!)
    }
  }
}


// MARK: - Check cache status
public extension DataCache {
  
  /**
  *  Cache result for checking whether an image is cached for a key.
  */
  public struct CacheCheckResult {
    public let cached: Bool
    public let cacheType: CacheType?
  }
  
  /**
  Check whether an image is cached for a key.
  
  :param: key Key for the image.
  
  :returns: The check result.
  */
  public func isImageCachedForKey(key: String) -> CacheCheckResult {
    
    if memoryCache.objectForKey(key) != nil {
      return CacheCheckResult(cached: true, cacheType: .Memory)
    }
    
    let filePath = cachePathForKey(key)
    
    if fileManager.fileExistsAtPath(filePath) {
      return CacheCheckResult(cached: true, cacheType: .Disk)
    }
    
    return CacheCheckResult(cached: false, cacheType: nil)
  }
  
  /**
  Get the hash for the key. This could be used for matching files.
  
  :param: key The key which is used for caching.
  
  :returns: Corresponding hash.
  */
  public func hashForKey(key: String) -> String {
    return cacheFileNameForKey(key)
  }
  
  /**
  Calculate the disk size taken by cache.
  It is the total allocated size of the cached files in bytes.
  
  :param: completionHandler Called with the calculated size when finishes.
  */
  public func calculateDiskCacheSizeWithCompletionHandler(completionHandler: ((size: UInt) -> ())?) {
    dispatch_async(ioQueue, { () -> Void in
      if let diskCacheURL = NSURL(fileURLWithPath: self.diskCachePath) {
        
        let resourceKeys = [NSURLIsDirectoryKey, NSURLTotalFileAllocatedSizeKey]
        var diskCacheSize: UInt = 0
        
        if let fileEnumerator = self.fileManager.enumeratorAtURL(diskCacheURL,
          includingPropertiesForKeys: resourceKeys,
          options: NSDirectoryEnumerationOptions.SkipsHiddenFiles,
          errorHandler: nil) {
            
            for fileURL in fileEnumerator.allObjects as! [NSURL] {
              
              if let resourceValues = fileURL.resourceValuesForKeys(resourceKeys, error: nil) {
                // If it is a Directory. Continue to next file URL.
                if let isDirectory = resourceValues[NSURLIsDirectoryKey]?.boolValue {
                  if isDirectory {
                    continue
                  }
                }
                
                if let fileSize = resourceValues[NSURLTotalFileAllocatedSizeKey] as? NSNumber {
                  diskCacheSize += fileSize.unsignedLongValue
                }
              }
              
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if let completionHandler = completionHandler {
            completionHandler(size: diskCacheSize)
          }
        })
        
      } else {
        println("Bad disk cache path. \(self.diskCachePath) is not a valid local directory path.")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if let completionHandler = completionHandler {
            completionHandler(size: 0)
          }
        })
      }
    })
  }
}

// MARK: - Internal Helper
extension DataCache {
  
//  func diskDataForKey(key: String) -> NSData? {
//    if let data = diskImageDataForKey(key) {
//        return data
//    } else {
//        return nil
//    }
//  }
  
  func diskDataForKey(key: String) -> NSData? {
    let filePath = cachePathForKey(key)
    return NSData(contentsOfFile: filePath)
  }
  
  func cachePathForKey(key: String) -> String {
    let fileName = cacheFileNameForKey(key)
    return diskCachePath.stringByAppendingPathComponent(fileName)
  }
  
  func cacheFileNameForKey(key: String) -> String {
    return key.bc_MD5()
  }
}

//extension UIImage {
//  var kf_imageCost: Int {
//    return Int(size.height * size.width * scale * scale)
//  }
//}

extension Dictionary {
  func keysSortedByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
    var array = Array(self)
    sort(&array) {
      let (lk, lv) = $0
      let (rk, rv) = $1
      return isOrderedBefore(lv, rv)
    }
    return array.map {
      let (k, v) = $0
      return k
    }
  }
}