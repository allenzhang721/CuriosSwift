//
//  LocalTemplateViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/27/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class LocalTemplateViewController: UIViewController {

    var templateList = [TemplateListModel]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

// MARK: - DataSource and Delegate
// MARK: -

extension LocalTemplateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - CollectionViewDataSource and Delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TemplateSelectCell", forIndexPath: indexPath) as! TemplateCollectionViewCell
//        let templateModel = TemplatesManager.instanShare.templateList[indexPath.item]
//        cell.setModel(templateModel);
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

      // open a book
      PublishIDRequest.requestWithComponents(getPublishID, aJsonParameter: nil) {[unowned self] (json) -> Void in
        
        if let publishID = json["newID"] as? String {
          println("publishID = \(publishID)")
          self.getBookWithBookID(publishID, getBookHandler: { [unowned self] (book) -> () in
            self.showEditViewControllerWithBook(book)
            })
        }
      }.sendRequest()
    }
}

// MARK: - IBAction
// MARK: -

extension LocalTemplateViewController {
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - Private Method
// MARK: -



