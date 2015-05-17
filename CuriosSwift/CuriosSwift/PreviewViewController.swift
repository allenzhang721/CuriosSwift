//
//  PreviewViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/18/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPreview()
    }

    func loadPreview() {
        
        let previewName = "CuriosPreview"
        let previewPath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(previewName)
        let previewURL = NSURL.fileURLWithPath(previewPath!, isDirectory: true)
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
        let cachePreview = cacheDirectory.stringByAppendingPathComponent(previewName) as String
        let indexFilePath = cachePreview.stringByAppendingPathComponent("index.html")
        let url = NSURL(fileURLWithPath: indexFilePath, isDirectory: false)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }

    @IBAction func backAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
