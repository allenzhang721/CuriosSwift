//
//  ViewController.swift
//  CuriosSwift
//
//  Created by 星宇陈 on 4/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class ViewController: UIViewController {
    
    struct MainStoryboard {
       static let name = "Main"
        struct viewControllers {
            static let editViewController = "editViewController"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDemoBook()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        setupEditViewController()
    }
}

extension ViewController {
    
    private func showDemoBook() {
        
        let demobookPath: String = NSBundle.mainBundle().pathForResource("main", ofType: "json", inDirectory: "res")!
        let data: AnyObject? = NSData.dataWithContentsOfMappedFile(demobookPath)
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
        
        let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! BookModel
//        println(book)
        
        for pageInfo in book.pagesInfo {
            
//            println(pageInfo)
            
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

