//
//  EMDownloader.swift
//  FileDownload
//
//  Created by Emiaostein on 7/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

// progress update block of downloader
public typealias JsonDownloaderProgressBlock = DownloadProgressBlock

/// Completion block of downloader.
public typealias JsonDownloaderCompletionHandler = ((json: AnyObject?, error: NSError?, URL: NSURL?) -> ())

/// Download task.
/// Download task.
public typealias RetrieveJsonDownloadTask = NSURLSessionDataTask

private let defaultDownloaderName = "default"
private let downloaderBarrierName = "com.botai.Curios.ImageDownloader.Barrier."
private let imageProcessQueueName = "com.botai.Curios.ImageDownloader.Process."
private let instance = JsonDownloader(name: defaultDownloaderName)

public class JsonDownloader: NSObject {
  
  class JsonFetchLoad {
    var callbacks = [CallbackPair]()
    var responseData = NSMutableData()
    var shouldDecode = false
  }
  
  // MARK: - Public property

  public var downloadTimeout: NSTimeInterval = 15.0
  
  // MARK: - Internal property
  let barrierQueue: dispatch_queue_t
  let processQueue: dispatch_queue_t
  
  typealias CallbackPair = (progressBlock: JsonDownloaderProgressBlock?, completionHander: JsonDownloaderCompletionHandler?)
  
  var fetchLoads = [NSURL: JsonFetchLoad]()
  
  // MARK: - Public method
  /// The default downloader.
  public class var defaultDownloader: JsonDownloader {
    return instance
  }
  
  public init(name: String) {
    if name.isEmpty {
      fatalError("[Kingfisher] You should specify a name for the downloader. A downloader with empty name is not permitted.")
    }
    
    barrierQueue = dispatch_queue_create(downloaderBarrierName + name, DISPATCH_QUEUE_CONCURRENT)
    processQueue = dispatch_queue_create(imageProcessQueueName + name, DISPATCH_QUEUE_CONCURRENT)
  }
  
  func fetchLoadForKey(key: NSURL) -> JsonFetchLoad? {
    var fetchLoad: JsonFetchLoad?
    dispatch_sync(barrierQueue, { () -> Void in
      fetchLoad = self.fetchLoads[key]
    })
    return fetchLoad
  }
}







public extension JsonDownloader {
  
  
  internal func downloadJsonWithURL(URL: NSURL,
    retrieveJsonTask: RetrieveJsonTask?,
    progressBlock: JsonDownloaderProgressBlock?,
    completionHandler: JsonDownloaderCompletionHandler?)
  {
    let timeout = self.downloadTimeout == 0.0 ? 15.0 : self.downloadTimeout
    
    let request = NSMutableURLRequest(URL: URL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: timeout)
    request.HTTPShouldUsePipelining = true
    
    
    if request.URL == nil {
      completionHandler?(json: nil, error: nil, URL: nil)
      return
    }
    
    setupProgressBlock(progressBlock, completionHandler: completionHandler, forURL: request.URL!) {(session, fetchLoad) -> Void in
      let task = session.dataTaskWithRequest(request)
      task.resume()
      retrieveJsonTask?.downloadTask = task
    }
  }
  
  // A single key may have multiple callbacks. Only download once.
  internal func setupProgressBlock(progressBlock: JsonDownloaderProgressBlock?, completionHandler: JsonDownloaderCompletionHandler?, forURL URL: NSURL, started: ((NSURLSession, JsonFetchLoad) -> Void)) {
    
    dispatch_barrier_sync(barrierQueue, { () -> Void in
      
      var create = false
      var loadObjectForURL = self.fetchLoads[URL]
      if  loadObjectForURL == nil {
        create = true
        loadObjectForURL = JsonFetchLoad()
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
extension JsonDownloader: NSURLSessionDataDelegate {
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
  
  private func callbackWithJson(Json: AnyObject?, error: NSError?, JsonURL: NSURL) {
    if let callbackPairs = fetchLoadForKey(JsonURL)?.callbacks {
      
      self.cleanForURL(JsonURL)
      
      for callbackPair in callbackPairs {
        callbackPair.completionHander?(json: Json, error: error, URL: JsonURL)
      }
    }
  }
  
  /**
  This method is exposed since the compiler requests. Do not call it.
  */
  public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    
    if let URL = task.originalRequest.URL {
      if let error = error { // Error happened
        callbackWithJson(nil, error: error, JsonURL: URL)
      } else { //Download finished without error
        
        // We are on main queue when receiving this.
        dispatch_async(processQueue, { () -> Void in
          
          if let fetchLoad = self.fetchLoadForKey(URL) {
            if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(fetchLoad.responseData, options: NSJSONReadingOptions(0), error: nil) {

              self.callbackWithJson(json, error: nil, JsonURL: URL)
              
            } else {
              // If server response is 304 (Not Modified), inform the callback handler with NotModified error.
              // It should be handled to get an image from cache, which is response of a manager object.
              if let res = task.response as? NSHTTPURLResponse where res.statusCode == 304 {
                self.callbackWithJson(nil, error: nil, JsonURL: URL)
                return
              }
              
              self.callbackWithJson(nil, error: nil, JsonURL: URL)
            }
          } else {
            self.callbackWithJson(nil, error: nil, JsonURL: URL)
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
//      if let trustedHosts = trustedHosts where trustedHosts.contains(challenge.protectionSpace.host) {
//        let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
//        completionHandler(.UseCredential, credential)
//        return
//      }
    }
    
    completionHandler(.PerformDefaultHandling, nil)
  }
  
}



















