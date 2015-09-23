//
//  UploadOperation.swift
//  CuriosSwift
//
//  Created by Emiaostein on 9/22/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Qiniu

class UploadOperation: Operation {
  
  let qnUploader = QNUploadManager(configuration: nil)
  
  let data: NSData
  let key: String
  let token: String
  
  init(aData: NSData, aKey: String, aToken: String) {
    self.data = aData
    self.key = aKey
    self.token = aToken
    super.init()
  }
  
  override func execute() {

    let cancelSignal = {[unowned self] () -> Bool in
      return false
    }
    if cancelled {
      finish(errors: [NSError(code: .ExecutionFailed, userInfo: nil)])
      return
    }
    
    //    NSOperation
    let defaultOptions = QNUploadOption.defaultOptions()
    let customOptions = QNUploadOption(mime: defaultOptions.mimeType, progressHandler:defaultOptions.progressHandler, params: defaultOptions.params, checkCrc: defaultOptions.checkCrc, cancellationSignal: cancelSignal)
    
    qnUploader.putData(data, key: key, token: token, complete: {[weak self] (responseInfo, uploadKey, response) -> Void in
      
      
      
      if let strongSelf = self {
        
        if strongSelf.cancelled {
          strongSelf.finish(errors: [NSError(code: .ExecutionFailed, userInfo: nil)])
          return
        }
        
        if response == nil {
          strongSelf.finish(errors: [NSError(code: .ConditionFailed, userInfo: ["operation": strongSelf])])
          debugPrint.p("upload failed")
        } else {
          strongSelf.finish(errors: [])
        }
        
      }
      }, option: customOptions)
  }
}