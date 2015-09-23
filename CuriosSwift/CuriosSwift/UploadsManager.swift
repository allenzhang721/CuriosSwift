//
//  UploadsManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/13/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation


protocol UploadsManagerDelegate: NSObjectProtocol {
  
  func uploadsManager(manager: UploadsManager, didFinishedUpload finished: Bool)
}

struct UploadsData {
  
  let data: NSData
  let key: String
  let token: String
  
}

class UploadsManager: NSObject {
  
  static let shareInstance = UploadsManager()
  
  private var finished = true
  private var totalCount = 0
  private var finishCount = 0
  private var failCount = 0
  private var compeletedBlock: ((Bool, Bool) -> ())?
  private var operations = [UploadOperation]()
  private var failedOperations = [String: UploadOperation]()
  
  private let uploadQueue: OperationQueue
  
  override init() {
    self.uploadQueue = OperationQueue()
    super.init()
    uploadQueue.delegate = self
    uploadQueue.addObserver(self, forKeyPath: "operationCount", options: .New, context: nil)
  }
  
  func uploadFinished() -> Bool {
//    dispatch_async(dispatch_get_main_queue(), { () -> Void in
    
      return finished
//    })
  }
  
  func setCompeletedHandler(block:((Bool, Bool) -> ())?) {   // completed, hasUploadFail
    compeletedBlock = block
  }
  
  func upload(datas: [NSData], keys: [String], tokens: [String]) {
    
    if !(datas.count > 0 && datas.count == keys.count && keys.count == tokens.count) {
      assert(false, "the upload count not equality, datas:\(datas.count),keys:\(keys.count),tokens:\(tokens.count)")
    }
    
    finished = false
    
    var ops = [UploadOperation]()
    
    for index in 0..<keys.count {
      let data = datas[index]
      let key = keys[index]
      let token = tokens[index]
      let operation = UploadOperation(aData: data, aKey: key, aToken: token)
      
      let blockObserver = BlockObserver(finishHandler: {[weak self] (operation, errors) -> Void in
        
        if let strongself = self {
          // error and upload fails, cache the operation
          if let operation = operation as? UploadOperation where !errors.isEmpty {
            strongself.failedOperations[key] = operation
          }
        }
      })
      operation.addObserver(blockObserver)
      ops.append(operation)
      operations.append(operation)
    }
    
    uploadQueue.addOperations(ops, waitUntilFinished: false)
  }
  
  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    
    if let queue = object as? OperationQueue, let count = change[NSKeyValueChangeNewKey] as? Int where keyPath == "operationCount" {
      
      if count <= 0 && operations.count <= 0 {
        
        if !finished {
          finished = true
          println("upload finished, failedCount: \(failedOperations.count)")
          compeletedBlock?(true, failedOperations.count > 0)
        }
      }
    }
  }
}

extension UploadsManager: OperationQueueDelegate {
  
  func operationQueue(operationQueue: OperationQueue, willAddOperation operation: NSOperation) {
  
    for (i, aoperation) in enumerate(operations) {
      
      if aoperation === operation {
        operations.removeAtIndex(i)
        break
      }
    }
  }
}