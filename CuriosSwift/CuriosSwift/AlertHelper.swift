//
//  AlertHelper.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/29/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class AlertHelper {
  
  
//  CONTINUE = "继续";
//  TIPS = "温馨提醒";
//NEEDCONNECTED = "您的网络已中断，请先连接网络，建议在在 WiFi 下使用";
  
  class func alert_needConnected() -> UIAlertController {
    
    //    KNEW = "知道了";
    //    INTERNETBROKEN = "网络已关闭";
    let title = localString("TIPS")
    let message = localString("NEEDCONNECTED")
    let cancel = localString("KNEW")
    
    return AlertHelper.alert_cancel(title, message: message, cancelTitle: cancel, canceled: nil)
  }
  
  class func alert_internetBroken() -> UIAlertController {
    
//    KNEW = "知道了";
//    INTERNETBROKEN = "网络已关闭";
    let title = localString("TIPS")
    let message = localString("INTERNETBROKEN")
    let cancel = localString("KNEW")
    
    return AlertHelper.alert_cancel(title, message: message, cancelTitle: cancel, canceled: nil)
  }
  
  class func alert_internetconnection(finished: (Bool) -> ()) -> UIAlertController {
    
    let title = localString("TIPS")
    let message = localString("NEEDCHANGETOWIFI")
    let confirm = localString("CONTINUE")
    let cancel = localString("CANCEL")
    
    return AlertHelper.alert_both(title, message: message, cancelTitle: cancel, confirmTitle: confirm, finished: finished)
  }
  
//  CANCEL = "取消";
//  CONFIRM = "确定";
  final private class func alert_cancel(title: String, message: String, cancelTitle: String ,canceled: ((Bool) -> ())?) -> UIAlertController {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let cancel = UIAlertAction(title: cancelTitle, style: .Cancel) { (action) -> Void in
      canceled?(true)
    }
    
    alert.addAction(cancel)
    
    return alert
  }
  
  final private class func alert_both(title: String, message: String, cancelTitle: String, confirmTitle: String ,finished: ((Bool) -> ())?) -> UIAlertController {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
//    let cancelTitle = localString("CANCEL")
    let cancel = UIAlertAction(title: cancelTitle, style: .Cancel) { (action) -> Void in
      finished?(false)
    }
    
//    let confirmTtitle = localString("CONFIRM")
    let confirm = UIAlertAction(title: confirmTitle, style: .Default) { (action) -> Void in
      
      finished?(true)
    }
    
    alert.addAction(cancel)
    alert.addAction(confirm)
    
    return alert
  }
  
}