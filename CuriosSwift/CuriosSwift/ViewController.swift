//
//  ViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    struct MainStoryboard {
       static let name = "Main"
        struct viewControllers {
            static let editViewController = "editViewController"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundlePath = NSBundle.mainBundle().bundlePath.stringByAppendingString("/res/Pages/page_1/images/aaaa.jpeg")
        imageView.image = UIImage(contentsOfFile: bundlePath)
        
        showDemoBook()
    }
    
    override func viewDidAppear(animated: Bool) {
        
//        setupEditViewController()
    }
}

extension ViewController {
    
    private func showDemoBook() {
        
        let demobookPath: String = NSBundle.mainBundle().pathForResource("main", ofType: "json", inDirectory: "res")!
        let data: AnyObject? = NSData.dataWithContentsOfMappedFile(demobookPath)
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
        
        let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! BookModel
        
        for pageInfo in book.pagesInfo {
            
            let pagePath = NSBundle.mainBundle().pathForResource(pageInfo["PageID"]!, ofType: "json", inDirectory: "res/Pages" + pageInfo["Path"]!)!
            let data: AnyObject? = NSData.dataWithContentsOfMappedFile(pagePath)
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
            let page = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! PageModel
            println(page.containers[0].animations[0].delay)
        }
    }
    
    private func setupEditViewController() {
        
        let editVC = UIStoryboard(name: MainStoryboard.name, bundle: nil) .instantiateViewControllerWithIdentifier(MainStoryboard.viewControllers.editViewController) as! EditViewController
        
        self.presentViewController(editVC, animated: false, completion: nil)
    }
    
    private func loadbook() {
        
        
    }
}

