//
//  EditViewController.swift
//  CuriosSwift
//
//  Created by 星宇陈 on 4/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class EditViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var pageModels: [PageModel] = []
    let queue = NSOperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        let normal = NormalLayout()
        collectionView.setCollectionViewLayout(normal, animated: false)
        collectionView.decelerationRate = 0.1
        pageModels = getPageModels()
    }
}


// MARK - IBAction
extension EditViewController {
    
    @IBAction func PanAction(sender: UIPanGestureRecognizer) {
    
        
    }
}


// MARK - Delegate and DateSource
extension EditViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pageModels.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PageCell
        cell.backgroundColor = UIColor.darkGrayColor()
        cell.configCell(pageModels[indexPath.item], queue: queue)
        return cell
    }
}

// MARK - Private Method
extension EditViewController {
    
    private func getPageModels() -> [PageModel] {
        
        let demobookPath: String = NSBundle.mainBundle().pathForResource("main", ofType: "json", inDirectory: "res")!
        let data: AnyObject? = NSData.dataWithContentsOfMappedFile(demobookPath)
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
        
        let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! BookModel
        //        println(book)
        
        var pageArray: [PageModel] = []
        for pageInfo in book.pagesInfo {
            
            //            println(pageInfo)
            
            let pagePath = NSBundle.mainBundle().pathForResource(pageInfo["PageID"]!, ofType: "json", inDirectory: "res/Pages" + pageInfo["Path"]!)!
            let data: AnyObject? = NSData.dataWithContentsOfMappedFile(pagePath)
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
            let page = MTLJSONAdapter.modelOfClass(PageModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! PageModel
//            println(page.containers[0].animations[0].delay)
            pageArray.append(page)
        }
        return pageArray
    }
}
