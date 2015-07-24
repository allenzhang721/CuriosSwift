//
//  ShareController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/23/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation


func shareWithTitle(title: String, descr: String, url: String, imageUrl: String, successBlock: (Bool) -> ()) {
  
  let container = ShareSDK.container()
  let imageAttach = ShareSDK.imageWithUrl(imageUrl)
  
  let contentObj = ShareSDK.content(descr,
    defaultContent: "",
    image: imageAttach,
    title: title,
    url: url,
    description: descr,
    mediaType: SSPublishContentMediaType(2))
  
  let authOptions = ShareSDK.authOptionsWithAutoAuth(true,
    allowCallback: true,
    authViewStyle: SSAuthViewStyleFullScreenPopup,
    viewDelegate: nil,
    authManagerViewDelegate: nil)
  
  let shareOptions = ShareSDK.simpleShareOptionsWithTitle("", shareViewDelegate: nil)
  
  let shareList: [AnyObject] = [22, 23, 21] // ShareType
  
  ShareSDK.showShareActionSheet(container,
    shareList: shareList,
    content: contentObj,
    statusBarTips: true,
    authOptions: authOptions,
    shareOptions: shareOptions) { (type, state: SSResponseState, platformInfo, error, end) -> Void in
      
      if Int(state.value) == 1 {

        successBlock(true)
        
      } else {
        successBlock(false)
      }
      
  }

  
}
