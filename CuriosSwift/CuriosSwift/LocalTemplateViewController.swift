//
//  LocalTemplateViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/27/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class LocalTemplateViewController: UIViewController {

    var templateList = [TemplateListModel]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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

// MARK: - DataSource and Delegate
// MARK: -

extension LocalTemplateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - CollectionViewDataSource and Delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return TemplatesManager.instanShare.templateList.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let selectedTemplate = TemplatesManager.instanShare.templateList[indexPath.item]
        let templateId = selectedTemplate.bookID
        let newTemplateId = UniqueIDString()
        let tempDirUrl = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let toUrl = NSURL(string: UsersManager.shareInstance.getUserID(), relativeToURL: tempDirUrl)
        if NSFileManager.defaultManager().createDirectoryAtURL(toUrl!, withIntermediateDirectories: true, attributes: nil, error: nil) {
            if TemplatesManager.instanShare.duplicateTemplateTo(templateId, toUrl: toUrl!.URLByAppendingPathComponent(newTemplateId)) {
                println("copy to Temp")
                
               let edit = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("editViewController") as! EditViewController
                edit.loadBookWith(newTemplateId)
                navigationController?.presentViewController(edit, animated: true, completion: nil)
            }
        }
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


