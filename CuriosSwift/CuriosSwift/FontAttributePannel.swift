//
//  FontPannel.swift
//  
//
//  Created by Emiaostein on 6/12/15.
//
//

import UIKit

class FontAttributePannel: Pannel {
    
    let items: [Item] = {
        
        let iconAndTitle = [
            "LeftAlignment",
            "CenterAlignment",
            "RightAlignment",
            "FontSizePlus",
            "FontSizeSubstract"
        ]
        
        let aItems = iconAndTitle.map { key -> Item in
            
            let name = key
            let iconName = "Font_" + key
            let titleName = NSLocalizedString(key, comment: "title")
            let action: IContainer? -> Void = { container in
                if let aComponent = container!.component as? ITextComponent {
//                    switch name {
//                        
//                        case "LeftAlignment":
//                        aComponent.setFontAligement(0)
//                    case "CenterAlignment":
//                        aComponent.setFontAligement(1)
//                    case "RightAlignment":
//                        aComponent.setFontAligement(2)
//                    case "FontSizePlus":
//                        aComponent.setFontSize(true)
//                    case "FontSizeSubstract":
//                        aComponent.setFontSize(false)
//                        
//                    default:
//                        return
//                    }
                }
            }
            let item = Item(name: name, iconName: iconName, titleName: titleName, action: action)
            
            return item
        }
        return aItems
        }()
    
    let collectionView: UICollectionView  = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0.0
        layout.itemSize = CGSize(width: 80, height: 85)
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(PannelCell.self, forCellWithReuseIdentifier: "fontPannel")
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

}

// MARK: - DataSource and Delegate
// MARK: -
extension FontAttributePannel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return items.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("fontPannel", forIndexPath: indexPath) as! PannelCell
        
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
                
                
                if indexPath.item == 3 {
                    
                    aDelegate.pannelDidSendEvent(.FontColorSetting, object: nil)
                } else {
                     item.action(aDelegate.pannelGetContainer())
                }
               
            }
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PannelCell {
            cell.updateSelected()
        }
    }
}


// MARK: - IBAction
// MARK: -


// MARK: - Private Method
// MARK: -
extension FontAttributePannel {
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
