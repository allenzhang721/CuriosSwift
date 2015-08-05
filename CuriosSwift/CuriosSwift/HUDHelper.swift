//
//  HUDHelper.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/28/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import SVProgressHUD


// Universal
//PUBLISH  = "发布";
//SHARE   = "分享";
//COPY    = "拷贝";
//SUCCESS = "成功";
//FAIL    = "失败";
//CANCEL = "取消";

//launch
//LOADING = "正在加载";

class HUD {
  
  // 正在同步
  class func save_sync() {
//    SYNCING = "同步中";

    let string = localString("SYNCING")
    HUD.show_status(string, userInteractable: false, autodismiss: false)
  }
  
  // 正在上传素材
  class func  preview_upload() {
    
//   UPLOADING = "上传素材中";
    let string = localString("UPLOADING")
    HUD.show_status(string, userInteractable: false, autodismiss: false)
  }
  
  
  // 登录中
  class func launch_Loading() {
    
    let string = localString("LAUNCHING")
    HUD.show_status(string, userInteractable: false, autodismiss: false)
  }
  
  // 拷贝成功
  class func share_copy_success() {
    
    let string = localString("COPY") + localString("SUCCESS")
    HUD.show(true, string: string, autodismiss: true)
  }
  
  // 分享成功
  class func share_success() {
    
    let string = localString("SHARE") + localString("SUCCESS")
    HUD.show(true, string: string, autodismiss: true)
  }
  
  
  // 分享失败
  class func share_fail() {
    
    let string = localString("SHARE") + localString("FAIL")
    HUD.show(true, string: string, autodismiss: true)
  }
  
  
  // MARK: - Show HUD Info
 final private class func show_status(string: String, userInteractable: Bool, autodismiss: Bool) {
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      
      userInteractable ? SVProgressHUD.showWithStatus(string) : SVProgressHUD.showWithStatus(string, maskType: .Black)
      
      if autodismiss {
        let time: NSTimeInterval = 1.0
        let delay = dispatch_time(DISPATCH_TIME_NOW,
          Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
          
          SVProgressHUD.dismiss()
        }
      }
    })
  }
  
  // MARK: - Show HUD base
  final private class func show(success: Bool, string: String, autodismiss: Bool) {
    
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      
      success ?
        SVProgressHUD.showSuccessWithStatus(string) :
        SVProgressHUD.showErrorWithStatus(string)
      
      if autodismiss {
        let time: NSTimeInterval = 1.0
        let delay = dispatch_time(DISPATCH_TIME_NOW,
          Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
          
          SVProgressHUD.dismiss()
        }
      }
    })
  }
  
  class func dismiss() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
    SVProgressHUD.dismiss()
    })
  }
}


