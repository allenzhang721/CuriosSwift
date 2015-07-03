//
//  ColorPickView.swift
//  
//
//  Created by Emiaostein on 7/2/15.
//
//

import UIKit

class ColorPickView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    typealias colorPickViewDidSelectedColorBlock = (String) -> Void
    typealias colorPickViewDismissColorBlock = () -> ()
//    typealias colorPickView

    @IBOutlet weak var collectionView: UICollectionView!
    var selectedBlock: colorPickViewDidSelectedColorBlock?
    var dismissBlock: colorPickViewDismissColorBlock?

    private var selectedColor: String = ""
    override func awakeFromNib() {
        
         collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorPickCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
    }
    
    func setDidSelectedBlock(block: colorPickViewDidSelectedColorBlock?) {
        
        selectedBlock = block
    }
    
    func setdissmissBlock(block: colorPickViewDismissColorBlock?) {
        
        dismissBlock = block
    }
    
    func setSelectedColorString(hexString: String) {
        
        selectedColor = hexString
        collectionView.reloadData()
    }
    
    
    @IBAction func dismissAction(sender: UIButton) {
        
        dismissBlock?()
    }
}

// MARK: - DataSource
extension ColorPickView {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return ColorManager.shareInstance.defaultColors.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorPickCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        let color = UIColor(hexString: ColorManager.shareInstance.defaultColors[indexPath.item])!
        cell.backgroundColor = color
        cell.layer.cornerRadius = 12.5
        
        if selectedColor == ColorManager.shareInstance.defaultColors[indexPath.item] {
            
            cell.layer.borderColor = UIColor.purpleColor().CGColor
            cell.layer.borderWidth = 2
        } else {
            cell.layer.borderColor = UIColor.purpleColor().CGColor
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        selectedColor = ColorManager.shareInstance.defaultColors[indexPath.item]
        selectedBlock?(ColorManager.shareInstance.defaultColors[indexPath.item])
        collectionView.reloadData()
    }
}
