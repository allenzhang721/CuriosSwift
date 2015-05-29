//
//  TemplateViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/9/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class TemplateViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var bookModels = [BookModel]()
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.pagingEnabled = true
        
        getTemplates()
    
    }

    
    func getSnapShotInPoint(point: CGPoint) -> UIView? {
        
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            return cell?.snapshotViewAfterScreenUpdates(false)
        } else {
            return nil
        }
        
    }
    
    func getPageModels(point: CGPoint) -> [PageModel]? {
        
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            let pageModels = bookModels[indexPath.item].pageModels
//            var ApageModels = [PageModel]()
//            for page in pageModels {
//                let aPage = page.copy() as! PageModel
//                ApageModels.append(aPage)
//            }
            
            return pageModels
        } else {
            
            return nil
        }
    }
}

// MARK: -
// MARK: - Delegate and DataSource

extension TemplateViewController: UICollectionViewDataSource {
    
    // MARK: - CollectionView DataSource and Delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return TemplatesManager.instanShare.templateList.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! TemplateCollectionViewCell
        
        return cell
    }
}

// MARK: -
// MARK: - IBAction



// MARK: -
// MARK: - Private Method

extension TemplateViewController {
    
    private func getTemplates() {
        
//        let templateListURL = documentDirectory(templates,templateList_)
        
//        let fileManager = NSFileManager.defaultManager()
//        let aBundlePath = NSBundle.mainBundle().resourcePath!
//        let templates = aBundlePath.stringByAppendingPathComponent("Templates")
//        let templatejson = templates.stringByAppendingPathComponent("templates.json")
//        let templatedata: AnyObject? = NSData.dataWithContentsOfMappedFile(templatejson)
//        let bookList: AnyObject? = NSJSONSerialization.JSONObjectWithData(templatedata as! NSData, options: NSJSONReadingOptions(0), error: nil)
//    
////        let demobookPath = file.stringByAppendingPathComponent("/main.json")
//        
//        if let abl = bookList as? NSArray {
//            for booDir in abl {
////                println(booDir)
//              let  bookFile = templates.stringByAppendingPathComponent(booDir as! String)
//                let bookjson = bookFile.stringByAppendingPathComponent("main.json")
//                let data: AnyObject? = NSData.dataWithContentsOfMappedFile(bookjson)
//                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions(0), error: nil)
//                let book = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json as! [NSObject : AnyObject], error: nil) as! BookModel
//                book.filePath = bookFile
//                book.paraserPageInfo()
//                bookModels.append(book)
//            }
//        }
    }
    
}
