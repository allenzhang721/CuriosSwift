//
//  ColorPickView.swift
//  
//
//  Created by Emiaostein on 7/2/15.
//
//

import UIKit

class ColorPickView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    typealias colorPickViewDidSelectedColorBlock = (UIColor) -> Void
//    typealias colorPickView

    @IBOutlet weak var collectionView: UICollectionView!
    var selectedBlock: colorPickViewDidSelectedColorBlock?

    override func awakeFromNib() {
        
        collectionView.dataSource = self
        
       func setDidSelectedBlock(block: colorPickViewDidSelectedColorBlock?) {
            
            selectedBlock = block
        }
    }
    
    
}

// MARK: - DataSource
extension ColorPickView {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 3
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorPickCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        cell.backgroundColor = UIColor.blueColor()
        cell.layer.cornerRadius = 25
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        selectedBlock?(UIColor.blueColor())
    }
}
