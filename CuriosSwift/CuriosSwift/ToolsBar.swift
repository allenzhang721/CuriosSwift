//
//  ToolsBar.swift
//  Curios
//
//  Created by Emiaostein on 6/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

protocol EditToolsBarProtocol: NSObjectProtocol {
    
    func editToolsBarDidSelectedAccessoryView(editToolsBar: ToolsBar)
}

private class EditToolsBarLayout: UICollectionViewFlowLayout {
    
}

class AccessoryView: UIView {
    
    typealias Action = () -> ()
    var action: Action?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, aAction: Action?) {
        super.init(frame: frame)
        action = aAction
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if let aAction = action {
            aAction()
        }
    }
}

private class EditToolsBarCell: UICollectionViewCell {
    
    private let button = UIButton.buttonWithType(.Custom) as! UIButton
    
    func setImage(image: UIImage) {
        button.setImage(image, forState: UIControlState.Normal)
    }
    
    func setTarget(target: AnyObject?, action: Selector) {
        
        button.removeTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        button.frame = bounds
        button.userInteractionEnabled = false
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let back = UIView(frame: bounds)
        back.layer.cornerRadius = 4
        back.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        selectedBackgroundView = back
        contentView.addSubview(button)
    }
    
    func sendActions() {
        
        button.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ToolsBar: UIControl {
    
    weak var delegate: EditToolsBarProtocol?
    var collectionView: UICollectionView!
    var items = [UIBarButtonItem]()
    var accessoryView: AccessoryView!
    var isShowAccessoryView = false
    
    private var selectedIndexPath: NSIndexPath?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(aframe: CGRect, aItems: [UIBarButtonItem], aDelegate: EditToolsBarProtocol) {
        super.init(frame: aframe)
        setupWithFrame(aframe, aItems: aItems, aDelegate: aDelegate)
    }

    private func setupWithFrame(aframe: CGRect, aItems: [UIBarButtonItem], aDelegate: EditToolsBarProtocol) {
        
        frame = aframe
        let layout = EditToolsBarLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.itemSize = CGSize(width: 44, height: 44)
        layout.minimumLineSpacing = 30
        layout.sectionInset = UIEdgeInsets(top: (CGRectGetHeight(aframe) - 44) / 2, left: 30, bottom: (CGRectGetHeight(aframe) - 44) / 2, right: 30)
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.registerClass(EditToolsBarCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.userInteractionEnabled = true
        delegate = aDelegate
        accessoryView = AccessoryView(frame: CGRect(x: bounds.width + aframe.height, y: 0, width: aframe.height, height: aframe.height), aAction: { [unowned self] () -> () in
            
            if let aDelegate = self.delegate {
                aDelegate.editToolsBarDidSelectedAccessoryView(self)
            }
            })
        items = aItems
        addSubview(collectionView)
        addSubview(accessoryView!)
    }
    
    func changeToItems(aItems: [UIBarButtonItem]) {
        
        items = aItems
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.collectionView.alpha = 0
            
            }) { (finished) -> Void in
                
                if finished {
                    
                    self.collectionView.reloadData()
                    
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        
                        self.collectionView.alpha = 1
                    })
                }
        }
    }
    
    func controlAccessoryView(show: Bool) {
        
        if accessoryView == nil {
            return
        }
        
        if let aAccessoryView = accessoryView {
            
            if show {
                
                if isShowAccessoryView == false {
                    isShowAccessoryView = true
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        aAccessoryView.frame.origin.x = self.bounds.width - self.bounds.height
                        self.collectionView.frame.size.width = self.bounds.width - self.bounds.height
                        //                        self.collectionView.contentOffset.x += self.defaultAccessoryViewWidth
                        
                    })
                }
            } else {
                if isShowAccessoryView == true {
                    isShowAccessoryView = false
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        aAccessoryView.frame.origin.x = self.bounds.width + self.bounds.height
                        self.collectionView.frame.size.width = self.bounds.width
                    })
                }
            }
        }
    }
    
    func showAccessoryView() {
        controlAccessoryView(true)
    }
    
    func hiddenAccessoryView() {
        controlAccessoryView(false)
        collectionView.deselectItemAtIndexPath(selectedIndexPath, animated: true)
        selectedIndexPath = nil
    }
    
    func cancel() {
        
        hiddenAccessoryView()
    }
}

// MARK: - DataSource and Delegate
// MARK: -
extension ToolsBar: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return items.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! EditToolsBarCell
        
        let barItem = items[indexPath.item]
        let image = barItem.image
        let target: AnyObject? = barItem.target
        let action = barItem.action
        cell.setImage(image!)
        cell.setTarget(target, action: action)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EditToolsBarCell
        cell.sendActions()
        
        
        if !isShowAccessoryView {
            showAccessoryView()
        }
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        selectedIndexPath = indexPath
        println("Cell selected")
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
}


// MARK: - IBAction
// MARK: -


// MARK: - Private Method
// MARK: -
