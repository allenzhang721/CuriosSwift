//
//  TemplatePagesViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 6/1/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class TemplatePagesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var templateBookId: String!
    var bookModel: BookModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
        loadTemplateWithId(templateBookId)
    }
    
    deinit {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
                let pageModels = [bookModel.pageModels[indexPath.item]]
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

// MARK: - DataSource and Delegate
// MARK: -
extension TemplatePagesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return bookModel.pagesInfo.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TemplatePageCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        return cell
    }
}

// MARK: - IBAction
// MARK: -


// MARK: - Private Method
// MARK: -
extension TemplatePagesViewController {
    
    func loadTemplateWithId(bookId: String) {
        let templateURL = documentDirectory(templates, bookId)
        let templatemainJsonURL = documentDirectory(templates, bookId, main_json)
        let data = NSData(contentsOfFile: templatemainJsonURL.path!)!
        let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as! [NSObject : AnyObject]
        
        bookModel = MTLJSONAdapter.modelOfClass(BookModel.self, fromJSONDictionary: json , error: nil) as! BookModel
//        bookModel.filePath = templateURL.path!
//        bookModel.paraserPageInfo()
    }
}