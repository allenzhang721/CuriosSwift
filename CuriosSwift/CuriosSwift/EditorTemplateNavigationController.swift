//
//  EditorTemplateNavigationController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/29/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class EditorTemplateNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        if let tempage = topViewController as? TemplatePagesViewController {
            
            return tempage.getSnapShotInPoint(point)
//            if let indexPath = collectionView.indexPathForItemAtPoint(point) {
//                let cell = collectionView.cellForItemAtIndexPath(indexPath)
//                return cell?.snapshotViewAfterScreenUpdates(false)
//            } else {
//                return nil
//            }
        } else {
            
            return nil
        }
    }
    
    func getPageModels(point: CGPoint) -> [PageModel]? {
        
        if let tempage = topViewController as? TemplatePagesViewController {
            
            return tempage.getPageModels(point)
            
//            if let indexPath = collectionView.indexPathForItemAtPoint(point) {
//                let pageModels = bookModels[indexPath.item].pageModels
//                //            var ApageModels = [PageModel]()
//                //            for page in pageModels {
//                //                let aPage = page.copy() as! PageModel
//                //                ApageModels.append(aPage)
//                //            }
//                
//                return pageModels
//            } else {
//                
//                return nil
//            }
        } else {
            
            return nil
        }
    }
}
