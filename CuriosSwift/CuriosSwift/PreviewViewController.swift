//
//  PreviewViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/18/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

protocol preViewControllerProtocol: NSObjectProtocol {
    
    func previewControllerGetBookModel(controller: PreviewViewController) -> BookModel
}

class PreviewViewController: UIViewController, UIViewControllerTransitioningDelegate, UploadSettingViewControllerProtocol {
    
    typealias RequestCompeletedBlock = (String?) -> Void
    typealias uploadCompletedBlock = (Bool) -> Void
    
    enum PreviewType {
        case Local, Internet
    }

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    weak var delegate: preViewControllerProtocol?
    var bookId: String!
    var uploader: UpLoadManager?
    var imageLoader: UpLoadManager?
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
        
        if let uploadNavi = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("UploadSettingNavigationController") as? UINavigationController, uploadVC = uploadNavi.topViewController as? UploadSettingViewController {
            
            webView.stopLoading()
            uploadNavi.modalPresentationStyle = .Custom
            uploadNavi.transitioningDelegate = self
            uploadVC.delegate = self
            presentViewController(uploadNavi, animated: true, completion: nil)
        }
        
        
//        let request = TokenRequest.requestWithComponents(["upload/publishUptoken"], aJsonParameter: nil) {[unowned self] JSON -> Void in
//            
//            println(JSON)
//            
//            if let aToken = JSON["uptoken"] as? String {
//                self.getPublishID(aToken)
//            }
//        }
//        
//        request.sendRequest()

    }
    
    func begainUpload() {
        
        // 1. get publishID
        getPublishID {[unowned self] (publishID) -> Void in
            
            if let aPublishID = publishID {
                println("1. get publishID success")
                
                // 2. get icon token
                self.getIConToken({ [unowned self] (iconToken) -> Void in
                    
                    if let aiconToken = iconToken {
                        println("2. get icon token success")
                        // 3. upload icon
                        self.uploadIcon(aPublishID, imageToken: aiconToken, uploadCompletedHandler: { [unowned self] (successed) -> Void in
                            
                            // 4. get publish token
                            if successed {
                                println("3. upload icon success")
                                
                                self.getPublishToken({[unowned self] (publishToken) -> Void in
                                    
                                    // 5. upload html5
                                    if let apublishToken = publishToken {
                                        println("4. get publish token success")
                                        
                                        self.uploadHtml(aPublishID, publishToken: apublishToken, uploadCompletedHandler: { [unowned self] (successed) -> Void in
                                            
                                            // 6. upload file info
                                            if successed {
                                                println("5. upload html5 success")
                                                self.uploadhtmlInfo(aPublishID, uploadCompletedHandler: { [unowned self](successed) -> Void in
                                                    
                                                    if successed {
                                                        println("6. upload file info success")
                                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                            
                                                            self.type = .Internet
                                                        })
                                                    }
                                                })
                                            }
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
                
            }
        }
        
    }
    
    func getPublishID(compeletedHandler: RequestCompeletedBlock) {
        
        let request = PublishIDRequest.requestWithComponents(["publish/getPublishID"], aJsonParameter: nil) {[unowned self] JSON -> Void in
            
            println(JSON)
            let publishID = JSON["newID"] as? String
            compeletedHandler(publishID)
        }
        
        request.sendRequest()
    }
    
    func getIConToken(compeletedHandler: RequestCompeletedBlock) {
        
        let request = TokenRequest.requestWithComponents(["upload/imageUptoken"], aJsonParameter: nil) {[unowned self] JSON -> Void in

            println(JSON)

            let aToken = JSON["uptoken"] as? String
            compeletedHandler(aToken)
        }
        
        request.sendRequest()
    }
    
    func uploadIcon(publishID: String, imageToken: String, uploadCompletedHandler: uploadCompletedBlock) {
        
        let userID = UsersManager.shareInstance.getUserID()
        let coverURL = temporaryDirectory(userID, bookId, "images", "icon.jpg")
        let aPublishID = publishID
        let aImageToken = imageToken
        let fileKey = userID + "/" + aPublishID + "images" + "/" + "icon.jpg"
        let filePath = coverURL.path!
        let fileDic: [String: String] = [fileKey: filePath]
        
        imageLoader = UpLoadManager(aFileKeys: fileDic, aToken: aImageToken, aCompleteHandler: { [unowned self] (result, successed) -> Void in
            
            println(result)
            uploadCompletedHandler(successed)
        })
        
        imageLoader?.start()
    }
    
    func getPublishToken(compeletedHandler: RequestCompeletedBlock) {
        
        let request = PublishIDRequest.requestWithComponents(["upload/publishUptoken"], aJsonParameter: nil) {[unowned self] JSON -> Void in
            
            let aToken = JSON["uptoken"] as? String
            compeletedHandler(aToken)
        }
        
        request.sendRequest()
    }
    
    func uploadHtml(publishID: String, publishToken: String, uploadCompletedHandler: uploadCompletedBlock) {
        
        
        let userID = UsersManager.shareInstance.getUserID()
        let bookID = bookId
        let bookURL = temporaryDirectory("CuriosPreview")
        let aPublishID = publishID
        let fileKeys = UpLoadManager.getFileKeys(bookURL, rootDirectoryName: "CuriosPreview", bookId: bookId, publishID: publishID, userDirectoryName: userID)
        
        self.uploader = UpLoadManager(aFileKeys: fileKeys, aToken: publishToken, aCompleteHandler: { [unowned self] (result, successed) -> Void in
            
            uploadCompletedHandler(successed)
//            if successed {
//                self.publishFile(aPublishID)
//                dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
//                    
//                    self.type = .Internet
//                    })
//            } else {
//                println("upload fail: \(result)")
//            }
            })
        
        self.uploader?.start()
    }
    
    func uploadhtmlInfo(publishID: String, uploadCompletedHandler: uploadCompletedBlock) {
        
        let userID = UsersManager.shareInstance.getUserID()
        println(userID)
        let aPublishID = publishID
        let iconURL = userID + "/" + aPublishID + "/" + "icon.png"
        let publishURL = userID + "/" + aPublishID + "/" + "index.html"
        
        let bookModel = delegate!.previewControllerGetBookModel(self)
        let aTitle = bookModel.title
        let aDesc = bookModel.desc
        
        let data = ["userID": userID,
            "publishID": aPublishID,
            "publishIconURL": iconURL,
            "publishURL": publishURL,
            "publishTitle": aTitle,
            "publishDesc": aDesc]
        
        let dataStringData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(0), error: nil)
        
        let dataString = NSString(data: dataStringData!, encoding: NSUTF8StringEncoding) as! String
        let aRequest = PublishFileRequest.requestWithComponents(["publish/publishFile"], aJsonParameter: dataString) {[unowned self] JSON -> Void in
            
            println("file = \(JSON)")
            if let resultType = JSON["resultType"] as? String where resultType == "success" {
                uploadCompletedHandler(true)
            } else {
                uploadCompletedHandler(false)
            }
        }
        
        aRequest.sendRequest()
        
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
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
            return UploadSettingAnimation()
        
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return OverlayPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    // MARK: - UploadSettingProtocol
    func uploadSettingViewControllerGetThumbImagePath(controller: UploadSettingViewController) -> String {

        let userID = UsersManager.shareInstance.getUserID()
        let coverURL = temporaryDirectory(userID, bookId, "images", "icon.jpg")
        
        return coverURL.path!
    }
    
    func uploadSettingViewControllerGetTitle(controller: UploadSettingViewController) -> String {
        
        if let aDelegate = delegate {
            
            let bookModel = aDelegate.previewControllerGetBookModel(self)
            return bookModel.title
        } else {
            return "title"
        }
    }
    
    func uploadSettingViewControllerGetdescription(controller: UploadSettingViewController) -> String {
        
        if let aDelegate = delegate {
            
            let bookModel = aDelegate.previewControllerGetBookModel(self)
            return bookModel.desc
        } else {
            return "desc"
        }
    }
    
    func uploadSettingViewControllerDidSettingFinished(controller: UploadSettingViewController, aTitle: String, aDescription: String) {
        
        if let aDelegate = delegate {
            
            let bookModel = aDelegate.previewControllerGetBookModel(self)
            bookModel.desc = aDescription
            bookModel.title = aTitle
            
            bookModel.saveBookInfo()
        }
        
        begainUpload()
    }
}
