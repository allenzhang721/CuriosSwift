//
//  TypographyPannel.swift
//
//
//  Created by Emiaostein on 6/12/15.
//
//

import UIKit

class TypographyPannel: Pannel {
    
    let items: [Item] = {
        
        let iconAndTitle = [
            "Moveforward",
            "MoveBack",
            "Lock"
        ]
        
        var aItems = [Item]()
        for (index, key) in enumerate(iconAndTitle) {
            
            let name = key
            let iconName = "Typography_" + key
            let titleName = NSLocalizedString(key, comment: "title")
            let action: IContainer? -> Void = { container in
                if let aContainer = container {
                    if index == 0 {
                        aContainer.sendForwoard()
                    } else if index == 1 {
                        aContainer.sendBack()
                    } else if index == 2 {
                        aContainer.lockLayer()
                    }
                }
            }
            let item = Item(name: name, iconName: iconName, titleName: titleName, action: action)
            aItems.append(item)
        }
        return aItems
    }()
    
    let collectionView: UICollectionView  = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0.0
        layout.itemSize = CGSize(width: 80, height: 85)
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(PannelCell.self, forCellWithReuseIdentifier: "typographyPannel")
                collectionView.allowsSelection = true
        return collectionView
        }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didSetDelegate() {
        
        if let aContainer = delegate?.pannelGetContainer() {
            
            if aContainer.lockedListener.value == true {
                
                let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            }
        }
    }
}


// MARK: - DataSource and Delegate
// MARK: -
extension TypographyPannel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return items.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("typographyPannel", forIndexPath: indexPath) as! PannelCell
        
        let item = items[indexPath.item]
        let image = UIImage(named: item.iconName)!
        cell.setImage(image, title: item.titleName)
                cell.updateSelected()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PannelCell {
            cell.updateSelected()
            if let aDelegate = delegate {
                let item = items[indexPath.item]
                item.action(aDelegate.pannelGetContainer())
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PannelCell {
            cell.updateSelected()
        }
    }
    
//    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//        
////        if indexPath.item == 2 {
////            return true
////        } else {
////            return false
////        }
//    }
}

// MARK: - IBAction
// MARK: -


// MARK: - Private Method
// MARK: -
extension TypographyPannel {
    private func setup() {
        addSubview(collectionView)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
    }
}
