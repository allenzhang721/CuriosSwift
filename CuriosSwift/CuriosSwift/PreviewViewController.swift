//
//  PreviewViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/18/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    enum PreviewType {
        case Local, Internet
    }

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    var bookId: String!
    var uploader: UpLoadManager?
    var type = PreviewType.Local {
        
        didSet {
            updateRightButton()
        }
    }
    
    deinit {
        webView.stopLoading()
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateRightButton()
        
        if type == .Local {
            loadPreviewWithURL(localPreviewURL())
        }
    }

    func loadPreviewWithURL(previewURL: NSURL) {
        let request = NSURLRequest(URL: previewURL)
        webView.loadRequest(request)
    }
    
    func localPreviewURL() -> NSURL {
        return temporaryDirectory("CuriosPreview", "index.html")
    }
    
    func publish(sender: UIBarButtonItem) {

        let request = TokenRequest.requestWithComponents(["upload/publishUptoken"], aJsonParameter: nil) {[unowned self] JSON -> Void in
            
            println(JSON)
            
            if let aToken = JSON["uptoken"] as? String {
                self.getPublishID(aToken)
            }
        }
        
        request.sendRequest()

    }
    
    func getPublishID(token: String) {
        
        let aToken = token
        let request = PublishIDRequest.requestWithComponents(["publish/getPublishID"], aJsonParameter: nil) {[unowned self] JSON -> Void in
            
            println(JSON)
            if let publishID = JSON["newID"] as? String {
                
                println(publishID)
                self.upload(publishID, token: aToken)
            }
        }
        
        request.sendRequest()
    }
    
    func share(sender: UIBarButtonItem) {
        
    }

    func upload(publishID: String, token: String) {
        let userID = UsersManager.shareInstance.getUserID()
        let bookID = bookId
        let bookURL = temporaryDirectory("CuriosPreview")
        let aPublishID = publishID
        let fileKeys = UpLoadManager.getFileKeys(bookURL, rootDirectoryName: "CuriosPreview", bookId: bookId, publishID: publishID, userDirectoryName: userID)
        
        self.uploader = UpLoadManager(aFileKeys: fileKeys, aToken: token, aCompleteHandler: { [unowned self] (result, successed) -> Void in
            
            
            if successed {
                self.publishFile(aPublishID)
                dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                    
                    self.type = .Internet
                    })
            } else {
                println("upload fail: \(result)")
            }
            })
        
        self.uploader?.start()
    }
    
    
    
    func publishFile(publishID: String) {
        
        let userID = UsersManager.shareInstance.getUserID()
        println(userID)
        let aPublishID = publishID
        let iconURL = userID + "/" + aPublishID + "/" + "icon.png"
        let publishURL = userID + "/" + aPublishID + "/" + "index.html"
        
        let data = ["userID": userID,
            "publishID": aPublishID,
            "publishIconURL": iconURL,
            "publishURL": publishURL,
            "publishTitle": "美丽的日子",
            "publishDesc": "在那最美的日子我和你在一起，手牵手一直到永远"]
        
        let dataStringData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(0), error: nil)
        
        let dataString = NSString(data: dataStringData!, encoding: NSUTF8StringEncoding) as! String
       let aRequest = PublishFileRequest.requestWithComponents(["publish/publishFile"], aJsonParameter: dataString) {[unowned self] JSON -> Void in
            
            println("file = \(JSON)")
        }
        
        aRequest.sendRequest()
    }
    
    func updateRightButton() {
        if type == .Local {
            let title = NSLocalizedString("Pubish", comment: "发布")
            let arightButton = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("publish:"))
            navigationItem.rightBarButtonItem = arightButton
        } else if type == .Internet{
            let title = NSLocalizedString("Share", comment: "分享")
            let arightButton = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("share:"))
            navigationItem.rightBarButtonItem = arightButton
        }
    }

    @IBAction func backAction(sender: UIBarButtonItem) {
        
        let fileManager = NSFileManager.defaultManager()
        let bookURL = temporaryDirectory("CuriosPreview")
        fileManager.removeItemAtURL(bookURL, error: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
