//
//  TemplateViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/9/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class TemplateViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.pagingEnabled = true
    }

    
    func getSnapShotInPoint(point: CGPoint) -> UIView? {
        
        let indexPath = collectionView.indexPathForItemAtPoint(point)
        let cell = collectionView.cellForItemAtIndexPath(indexPath!)
        return cell?.snapshotViewAfterScreenUpdates(false)
    }
    
    
}

// MARK: - Delegate and DataSource
extension TemplateViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 20
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! TemplateCollectionViewCell
        
        return cell
    }
}
