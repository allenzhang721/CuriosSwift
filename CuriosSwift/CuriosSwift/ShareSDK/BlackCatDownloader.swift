//
//  EMBlackCatDownloader.swift
//  EMDownloadCacheManager
//
//  Created by Emiaostein on 7/31/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

/// Progress update block of downloader.
public typealias DataDownloaderProgressBlock = DownloadProgressBlock

/// Completion block of downloader.
public typealias DataDownloaderCompletionHandler = ((data: NSData?, error: NSError?, URL: NSURL?) -> ())

/// Download task.
public typealias RetrieveDataDownloadTask = NSURLSessionDataTask

private let defaultDownloaderName = "default"
private let downloaderBarrierName = "com.emiaostein.BlackCat.DataDownloader.Barrier."
private let imageProcessQueueName = "com.emiaostein.BlackCat.DataDownloader.Process."
private let instance = DataDownloader(name: defaultDownloaderName)


/**
The error code.

- BadData: The downloaded data is not an image or the data is corrupted.
- NotModified: The remote server responsed a 304 code. No image data downloaded.
- InvalidURL: The URL is invalid.
*/
public enum BlackCatError: Int {
  case BadData = 10000
  case NotModified = 10001
  case InvalidURL = 20000
}

/**
*	Protocol of `ImageDownloader`.
*/
@objc public protocol DataDownloaderDelegate {
  /**
  Called when the `ImageDownloader` object successfully downloaded an image from specified URL.
  
  :param: downloader The `ImageDownloader` object finishes the downloading.
  :param: image      Downloaded image.
  :param: URL        URL of the original request URL.
  :param: response   The response object of the downloading process.
  */
  optional func dataDownloader(downloader: DataDownloader, didDownloadData data: NSData, forURL URL: NSURL, withResponse response: NSURLResponse)
}

/**
*	`ImageDownloader` represents a downloading manager for requesting the image with a URL from server.
*/
public class DataDownloader: NSObject {
  
  class DataFetchLoad {
    var callbacks = [CallbackPair]()
    var responseData = NSMutableData()
//    var shouldDecode = false
//    var scale = BlackCatManager.DefaultOptions.scale
  }
  
  // MARK: - Public property
  
  /// This closure will be applied to the image download request before it being sent. You can modify the request for some customizing purpose, like adding auth token to the header or do a url mapping.
  public var requestModifier: (NSMutableURLRequest -> Void)?
  
  /// The duration before the download is timeout. Default is 15 seconds.
  public var downloadTimeout: NSTimeInterval = 15.0
  
  /// A set of trusted hosts when receiving server trust challenges. A challenge with host name contained in this set will be ignored. You can use this set to specify the self-signed site.
  public var trustedHosts: Set<String>?
  
  /// Delegate of this `ImageDownloader` object. See `ImageDownloaderDelegate` protocol for more.
  public weak var delegate: DataDownloaderDelegate?
  
  // MARK: - Internal property
  let barrierQueue: dispatch_queue_t
  let processQueue: dispatch_queue_t
  
  typealias CallbackPair = (progressBlock: DataDownloaderProgressBlock?, completionHander: DataDownloaderCompletionHandler?)
  
  var fetchLoads = [NSURL: DataFetchLoad]()
  
  // MARK: - Public method
  /// The default downloader.
  public class var defaultDownloader: DataDownloader {
    return instance
  }
  
  /**
  Init a downloader with name.
  
  :param: name The name for the downloader. It should not be empty.
  
  :returns: The downloader object.
  */
  public init(name: String) {
    if name.isEmpty {
      fatalError("[BlackCat] You should specify a name for the downloader. A downloader with empty name is not permitted.")
    }
    
    barrierQueue = dispatch_queue_create(downloaderBarrierName + name, DISPATCH_QUEUE_CONCURRENT)
    processQueue = dispatch_queue_create(imageProcessQueueName + name, DISPATCH_QUEUE_CONCURRENT)
  }
  
  func fetchLoadForKey(key: NSURL) -> DataFetchLoad? {
    var fetchLoad: DataFetchLoad?
    dispatch_sync(barrierQueue, { () -> Void in
      fetchLoad = self.fetchLoads[key]
    })
    return fetchLoad
  }
}

// MARK: - Download method
public extension DataDownloader {
  /**
  Download an image with a URL.
  
  :param: URL               Target URL.
  :param: progressBlock     Called when the download progress updated.
  :param: completionHandler Called when the download progress finishes.
  */
  public func downloadImageWithURL(URL: NSURL,
    progressBlock: DataDownloaderProgressBlock?,
    completionHandler: DataDownloaderCompletionHandler?)
  {
    downloadDataWithURL(URL, options: BlackCatManager.DefaultOptions, progressBlock: progressBlock, completionHandler: completionHandler)
  }
  
  /**
  Download an image with a URL and option.
  
  :param: URL               Target URL.
  :param: options           The options could control download behavior. See `BlackCatManager.Options`
  :param: progressBlock     Called when the download progress updated.
  :param: completionHandler Called when the download progress finishes.
  */
  public func downloadDataWithURL(URL: NSURL,
    options: BlackCatManager.Options,
    progressBlock: DataDownloaderProgressBlock?,
    completionHandler: DataDownloaderCompletionHandler?)
  {
    downloadDataWithURL(URL,
      retrieveImageTask: nil,
      options: options,
      progressBlock: progressBlock,
      completionHandler: completionHandler)
  }
  
  internal func downloadDataWithURL(URL: NSURL,
    retrieveImageTask: RetrieveDataTask?,
    options: BlackCatManager.Options,
    progressBlock: DataDownloaderProgressBlock?,
    completionHandler: DataDownloaderCompletionHandler?)
  {
    let timeout = self.downloadTimeout == 0.0 ? 15.0 : self.downloadTimeout
    
    // We need to set the URL as the load key. So before setup progress, we need to ask the `requestModifier` for a final URL.
    let request = NSMutableURLRequest(URL: URL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: timeout)
    request.HTTPShouldUsePipelining = true
    
    self.requestModifier?(request)
    
    // There is a possiblility that request modifier changed the url to `nil`
    if request.URL == nil {
      completionHandler?(data: nil, error: NSError(domain: BlackCatErrorDomain, code: BlackCatError.InvalidURL.rawValue, userInfo: nil), URL: nil)
      return
    }
    
    setupProgressBlock(progressBlock, completionHandler: completionHandler, forURL: request.URL!) {(session, fetchLoad) -> Void in
      let task = session.dataTaskWithRequest(request)
      
      task.priority = options.lowPriority ? NSURLSessionTaskPriorityLow : NSURLSessionTaskPriorityDefault
      task.resume()
      
      retrieveImageTask?.downloadTask = task
    }
  }
  
  // A single key may have multiple callbacks. Only download once.
  internal func setupProgressBlock(progressBlock: DataDownloaderProgressBlock?, completionHandler: DataDownloaderCompletionHandler?, forURL URL: NSURL, started: ((NSURLSession, DataFetchLoad) -> Void)) {
    
    dispatch_barrier_sync(barrierQueue, { () -> Void in
      
      var create = false
      var loadObjectForURL = self.fetchLoads[URL]
      if  loadObjectForURL == nil {
        create = true
        loadObjectForURL = DataFetchLoad()
      }
      
      let callbackPair = (progressBlock: progressBlock, completionHander: completionHandler)
      loadObjectForURL!.callbacks.append(callbackPair)
      self.fetchLoads[URL] = loadObjectForURL!
      
      if create {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        started(session, loadObjectForURL!)
      }
    })
  }
  
  func cleanForURL(URL: NSURL) {
    dispatch_barrier_sync(barrierQueue, { () -> Void in
      self.fetchLoads.removeValueForKey(URL)
      return
    })
  }
}

// MARK: - NSURLSessionTaskDelegate
extension DataDownloader: NSURLSessionDataDelegate {
  /**
  This method is exposed since the compiler requests. Do not call it.
  */
  public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
    
    if let URL = dataTask.originalRequest.URL, callbackPairs = fetchLoadForKey(URL)?.callbacks {
      for callbackPair in callbackPairs {
        callbackPair.progressBlock?(receivedSize: 0, totalSize: response.expectedContentLength)
      }
    }
    completionHandler(NSURLSessionResponseDisposition.Allow)
  }
  
  /**
  This method is exposed since the compiler requests. Do not call it.
  */
  public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    
    if let URL = dataTask.originalRequest.URL, fetchLoad = fetchLoadForKey(URL) {
      fetchLoad.responseData.appendData(data)
      for callbackPair in fetchLoad.callbacks {
        callbackPair.progressBlock?(receivedSize: Int64(fetchLoad.responseData.length), totalSize: dataTask.response!.expectedContentLength)
      }
    }
  }
  
  private func callbackWithData(data: NSData?, error: NSError?, URL: NSURL) {
    if let callbackPairs = fetchLoadForKey(URL)?.callbacks {
      
      self.cleanForURL(URL)
      
      for callbackPair in callbackPairs {
        callbackPair.completionHander?(data: data, error: error, URL: URL)
      }
    }
  }
  
  /**
  This method is exposed since the compiler requests. Do not call it.
  */
  public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    
    if let URL = task.originalRequest.URL {
      if let error = error { // Error happened
        callbackWithData(nil, error: error, URL: URL)
      } else { //Download finished without error
        
        // We are on main queue when receiving this.
        dispatch_async(processQueue, { () -> Void in
          
          if let fetchLoad = self.fetchLoadForKey(URL) {
            let data = fetchLoad.responseData
            if data.length > 0 {
              self.delegate?.dataDownloader?(self, didDownloadData: data, forURL: URL, withResponse: task.response!)
              
//              if fetchLoad.shouldDecode {
//                self.callbackWithImage(image.kf_decodedImage(scale: fetchLoad.scale), error: nil, imageURL: URL)
//              } else {
                self.callbackWithData(data, error: nil, URL: URL)
//              }
              
            } else {
              // If server response is 304 (Not Modified), inform the callback handler with NotModified error.
              // It should be handled to get an image from cache, which is response of a manager object.
              if let res = task.response as? NSHTTPURLResponse where res.statusCode == 304 {
                self.callbackWithData(nil, error: NSError(domain: BlackCatErrorDomain, code: BlackCatError.NotModified.rawValue, userInfo: nil), URL: URL)
                return
              }
              
              self.callbackWithData(nil, error: NSError(domain: BlackCatErrorDomain, code: BlackCatError.BadData.rawValue, userInfo: nil), URL: URL)
            }
          } else {
            self.callbackWithData(nil, error: NSError(domain: BlackCatErrorDomain, code: BlackCatError.BadData.rawValue, userInfo: nil), URL: URL)
          }
        })
      }
    }
  }
  
  /**
  This method is exposed since the compiler requests. Do not call it.
  */
  public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
    
    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
      if let trustedHosts = trustedHosts where trustedHosts.contains(challenge.protectionSpace.host) {
        let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
        completionHandler(.UseCredential, credential)
        return
      }
    }
    
    completionHandler(.PerformDefaultHandling, nil)
  }
  
}