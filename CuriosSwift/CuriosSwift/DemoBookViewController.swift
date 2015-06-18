//
//  DemoBookViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/22/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class DemoBookViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        OpenBookAction(UIButton())
    }
    
    @IBAction func OpenBookAction(sender: UIButton) {
        
        
        let demoBookID = "QWERTASDFGZXCVB"
        let demobookPath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(demoBookID)
        let demoBookURL = NSURL.fileURLWithPath(demobookPath!, isDirectory: true)
        
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
        let documentBookPath = documentPath.stringByAppendingPathComponent(demoBookID)
        let documentBookURL = NSURL.fileURLWithPath(documentBookPath, isDirectory: true)
        if !NSFileManager.defaultManager().fileExistsAtPath(documentBookPath) {
            
            NSFileManager.defaultManager().copyItemAtURL(demoBookURL!, toURL: documentBookURL!, error: nil)
        }
        
        let toBookPath = NSTemporaryDirectory().stringByAppendingPathComponent(demoBookID)
        let toBookURL = NSURL.fileURLWithPath(toBookPath, isDirectory: true)
        NSFileManager.defaultManager().removeItemAtURL(toBookURL!, error: nil)
        if NSFileManager.defaultManager().copyItemAtURL(documentBookURL!, toURL: toBookURL!, error: nil) {
            
            let editVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editViewController") as! EditViewController
            
            presentViewController(editVC, animated: true, completion: nil)
        }
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
