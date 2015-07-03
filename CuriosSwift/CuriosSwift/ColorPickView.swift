//
//  ColorPickView.swift
//  
//
//  Created by Emiaostein on 7/2/15.
//
//

import UIKit

class ColorPickView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    let colorDic: [[String: CGFloat]] = [
        ["red": 0 ,"green": 0, "blue": 0,"alpha": 1.0],  // White
        ["red": 1.00 ,"green": 1.00, "blue": 1.00,"alpha": 1.0],  // White
        ["red": 1.00 ,"green": 0, "blue": 0.02,"alpha": 1.0],  // red
        ["red": 1 ,"green": 0.65, "blue": 0,"alpha": 1.0],  // orange
        ["red": 0.97 ,"green": 0.94, "blue": 0,"alpha": 1.0],  // yellow
        ["red": 0.28 ,"green": 0.87, "blue": 0.13,"alpha": 1.0],  // green
        ["red": 0 ,"green": 0.93, "blue": 0.78,"alpha": 1.0],  // lightGreen
        ["red": 0.0 ,"green": 0.65, "blue": 0.90,"alpha": 1.0]  // blue
    ]
    
    typealias colorPickViewDidSelectedColorBlock = ([String: CGFloat]) -> Void
    typealias colorPickViewDismissColorBlock = () -> ()
//    typealias colorPickView

    @IBOutlet weak var collectionView: UICollectionView!
    var selectedBlock: colorPickViewDidSelectedColorBlock?
    var dismissBlock: colorPickViewDismissColorBlock?

    override func awakeFromNib() {
        
         collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorPickCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setDidSelectedBlock(block: colorPickViewDidSelectedColorBlock?) {
        
        selectedBlock = block
    }
    
    func setdissmissBlock(block: colorPickViewDismissColorBlock?) {
        
        dismissBlock = block
    }
    
    
    @IBAction func dismissAction(sender: UIButton) {
        
        dismissBlock?()
    }
}

// MARK: - DataSource
extension ColorPickView {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return colorDic.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorPickCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        cell.backgroundColor = colorWithDic(colorDic[indexPath.item])
        cell.layer.cornerRadius = cell.bounds.width / 2.0
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 1.0
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        selectedBlock?(colorDic[indexPath.item])
    }
    
    func colorWithDic(dic: [String : CGFloat]) -> UIColor {
        
        let red = dic["red"]!
        let blue = dic["blue"]!
        let green = dic["green"]!
        let alpha = dic["alpha"]!
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        return color
    }
}
