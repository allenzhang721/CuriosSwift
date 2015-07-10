//
//  ImageUplodRequest.swift
//  
//
//  Created by Emiaostein on 7/6/15.
//
//

import UIKit
import Qiniu

class FileUplodRequest: BaseRequst {
    
    class func uploadFileWithKeyFile(keyfiles: [String: String]) {
        
        // token 
        
        let keys = keyfiles.keys.array
        let keyList = keys.map { return  ["key": $0]}
        let keyListDic = ["list": keyList]
        
        let json = NSJSONSerialization.dataWithJSONObject(keyListDic, options: NSJSONWritingOptions(0), error: nil)
        let string = NSString(data: json!, encoding: NSUTF8StringEncoding) as! String
       let base = ImageTokenRequest.requestWith(string) { (result) -> Void in
            
            if let keyFileAndTokenDic = result["list"] as? [[String:String]] {
                
                for dic in keyFileAndTokenDic {
                    
//                    let fileKey = dic.keys.array.filter{ $0 != "upToken"}
                    let key = dic["key"]!
                    let filePath = keyfiles[key]
                    let token = dic["upToken"]
                    
                    println("dic = \(dic)")
                    
                    QNUploadManager.sharedInstanceWithConfiguration(nil).putFile(filePath, key: key, token: token, complete: { (responseInfo, key, response) -> Void in
                        
                        if response != nil {
                            
                            println(responseInfo)
                          
                        } else {
                            
                            println("image uopload response == nil")
                        }
                        
                    }, option: nil)
                
                }
            }
        }
      
        base.sendRequest()
    }
}
