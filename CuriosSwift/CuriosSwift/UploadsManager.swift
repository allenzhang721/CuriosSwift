//
//  UploadsManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/13/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Qiniu

protocol UploadsManagerDelegate: NSObjectProtocol {
  
  func uploadsManager(manager: UploadsManager, didFinishedUpload finished: Bool)
}

class UploadsManager {
  
  static let shareInstance = UploadsManager()
  
  let qnUploader = QNUploadManager(configuration: nil)
  
  private var finished = true
  private var totalCount = 0
  private var finishCount = 0
  private var failCount = 0
  private var compeletedBlock: ((Bool) -> ())?
  
  // cancel
  // finishedBlock: (finished) -> ()
  // uploading: Bool
  //
  
  func setCompeletedHandler(block:((Bool) -> ())?) {
    compeletedBlock = block
  }
  
  func upload(datas: [NSData], keys: [String], tokens: [String]) {
    
    if !(datas.count > 0 && datas.count == keys.count && keys.count == tokens.count) {
      assert(false, "the upload count not equality, datas:\(datas.count),keys:\(keys.count),tokens:\(tokens.count)")
    }
    
    finished = false
    
    totalCount += tokens.count
    
    println("totalCount = \(totalCount)")
    println("finishedCount = \(finishCount)")
    
    let cancelSignal = {[unowned self] () -> Bool in
      return false
    }
    
    let defaultOptions = QNUploadOption.defaultOptions()
    let customOptions = QNUploadOption(mime: defaultOptions.mimeType, progressHandler:defaultOptions.progressHandler, params: defaultOptions.params, checkCrc: defaultOptions.checkCrc, cancellationSignal: cancelSignal)
    
    for index in 0..<keys.count {
      
      // upload data
      let data = datas[index]
      let key = keys[index]
      let token = tokens[index]
      qnUploader.putData(data, key: key, token: token, complete: {[unowned self] (responseInfo, uploadKey, response) -> Void in
        
        self.finishCount += 1
        
        if response == nil {
          self.failCount += 1
        }
        
        if self.finishCount == self.totalCount {
          println("uploads finished")
          self.finished = true
          self.compeletedBlock?(true)
        }
        
      }, option: customOptions)
    }
  }
}