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
        
        let userID = UsersManager.shareInstance.getUserID()
        let bookID = bookId
        let bookURL = temporaryDirectory("CuriosPreview")
        let fileKeys = UpLoadManager.getFileKeys(bookURL, rootDirectoryName: "CuriosPreview", bookId: bookId, userDirectoryName: userID)
        println(bookID)
        let token = "zXqNlKjpzQpFzydm6OCcngSa76aVNp-SwmqG-kUy:r-DjVHj8Ri2LjOMTXLUaYaKBKlQ=:eyJzY29wZSI6ImN1cmlvc3B1Ymxpc2giLCJkZWFkbGluZSI6MTQzNDg4NTc1Mn0="
        uploader = UpLoadManager(aFileKeys: fileKeys, aToken: token, aCompleteHandler: { [unowned self] (result, finished) -> Void in
            
            if finished {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.type = .Internet
                    println("http://7xjqsu.com2.z0.glb.qiniucdn.com/" + "\(userID)" + "/" + "\(bookID)" + "/index.html")
                })
                
                
            }
        })
        
        uploader?.start()
    }
    
    func share(sender: UIBarButtonItem) {
        
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
