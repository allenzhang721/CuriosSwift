//
//  EMTemplatesCache.swift
//  FileDownload
//
//  Created by Emiaostein on 7/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

public enum EMCacheType {
  case None, Memory, Disk
}

private let defaultCacheName = "default"
private let cacheReverseDNS = "com.botai.Curios.JsonCache."
private let ioQueueName = "com.botai.Curios.JsonCache.ioQueue."
private let processQueueName = "com.botai.Curios.JsonCache.processQueue."

private let defaultCacheInstance = JsonCache(name: defaultCacheName)

public typealias RetrieveJsonDiskTask = dispatch_block_t


public class JsonCache {
  
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
  
  /// The largest disk size can be taken for the cache. It is the total allocated size of cached files in bytes. Default is 0, which means no limit.
  public var maxDiskCacheSize: UInt = 0
  
  private let processQueue: dispatch_queue_t
  
  /// The default cache.
  public class var defaultCache: JsonCache {
    return defaultCacheInstance
  }

  public init(name: String) {
    
    if name.isEmpty {
      fatalError("[JsonCache] You should specify a name for the cache. A cache with empty name is not permitted.")
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
  }
}


public extension JsonCache {
  
  public func storeImage(Json: AnyObject, length: Int, forKey key: String) {
    storeJson(Json, length: length, forKey: key, toDisk: true, completionHandler: nil)
  }
  
  public func storeJson(Json: AnyObject, length: Int, forKey key: String, toDisk: Bool, completionHandler: (() -> ())?) {
    memoryCache.setObject(Json, forKey: key, cost: length)
    
    if toDisk {
      dispatch_async(ioQueue, { () -> Void in
        if let data = NSJSONSerialization.dataWithJSONObject(Json, options: NSJSONWritingOptions(0), error: nil) {
          
          if !self.fileManager.fileExistsAtPath(self.diskCachePath) {
            self.fileManager.createDirectoryAtPath(self.diskCachePath, withIntermediateDirectories: true, attributes: nil, error: nil)
          }
          
          println(self.cachePathForKey(key))
          if self.fileManager.createFileAtPath(self.cachePathForKey(key), contents: data, attributes: nil) {
            
            
          }
          
          if let handler = completionHandler {
            dispatch_async(dispatch_get_main_queue()) {
              handler()
            }
          }
          
        } else {
          if let handler = completionHandler {
            dispatch_async(dispatch_get_main_queue()) {
              handler()
            }
          }
        }
      })
    } else {
      if let handler = completionHandler {
        handler()
      }
    }
  }
  
  // remove json
  public func removeJsonForKey(key: String) {
    removeJsonForKey(key, fromDisk: true, completionHandler: nil)
  }
  
  
  public func removeJsonForKey(key: String, fromDisk: Bool, completionHandler: (() -> ())?) {
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
extension JsonCache {
  
  public func retrieveJsonForKey(key: String, completionHandler: ((AnyObject?, EMCacheType!) -> ())?) -> RetrieveJsonDiskTask? {
    // No completion handler. Not start working and early return.
    if (completionHandler == nil) {
      return dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {}
    }
    
    let block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
      if let json: AnyObject = self.retrieveJsonInMemoryCacheForKey(key) {
        
          completionHandler?(json, .Memory)
      } else {
        
        //Begin to load image from disk
        dispatch_async(self.ioQueue, { () -> Void in
          
          if let result = self.retrieveJsonInDiskCacheForKey(key) {
            
              self.storeJson(result.0, length: result.1, forKey: key, toDisk: false, completionHandler: nil)
              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let completionHandler = completionHandler {
                  completionHandler(result.0, .Disk)
                }
              })
            
          } else {
            // No image found from either memory or disk
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              if let completionHandler = completionHandler {
                completionHandler(nil, nil)
              }
            })
          }
        })
      }
    }
    
    dispatch_async(dispatch_get_main_queue(), block)
    return block
  }
  
  
  public func retrieveJsonInMemoryCacheForKey(key: String) -> AnyObject? {
    return memoryCache.objectForKey(key)
  }
  
  
  public func retrieveJsonInDiskCacheForKey(key: String) -> (AnyObject, Int)? {
    return diskJsonForKey(key)
  }
}


// MARK: - Clear & Clean
extension JsonCache {
  
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
}


// MARK: - Check cache Status
public extension JsonCache {
  
  /**
  *  Cache result for checking whether an image is cached for a key.
  */
  public struct CacheCheckResult {
    public let cached: Bool
    public let cacheType: EMCacheType?
  }
  
  /**
  Check whether an image is cached for a key.
  
  :param: key Key for the image.
  
  :returns: The check result.
  */
  public func isJsonCachedForKey(key: String) -> CacheCheckResult {
    
    if memoryCache.objectForKey(key) != nil {
      return CacheCheckResult(cached: true, cacheType: .Memory)
    }
    
    let filePath = cachePathForKey(key)
    
    if fileManager.fileExistsAtPath(filePath) {
      return CacheCheckResult(cached: true, cacheType: .Disk)
    }
    
    return CacheCheckResult(cached: false, cacheType: nil)
  }
}



























// MARK: - Internal Helper
extension JsonCache {
  
  func diskJsonForKey(key: String) -> (AnyObject, Int)? {
    if let data = diskJsonDataForKey(key) {
      if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) {
        return (json, data.length)
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
  func diskJsonDataForKey(key: String) -> NSData? {
    let filePath = cachePathForKey(key)
    return NSData(contentsOfFile: filePath)
  }
  
  func cachePathForKey(key: String) -> String {
    let fileName = cacheFileNameForKey(key)
    return diskCachePath.stringByAppendingPathComponent(fileName)
  }
  
  func cacheFileNameForKey(key: String) -> String {
    return key.em_MD5()

  }
  
}




