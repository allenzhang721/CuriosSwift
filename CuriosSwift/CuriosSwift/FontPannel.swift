//
//  FontPannel.swift
//  
//
//  Created by Emiaostein on 6/29/15.
//
//

import UIKit

class FontPannel: Pannel {
    
    let items: [EventItem] = {
        
        let iconAndTitle = FontsManager.share.getFontsList().map { fontInfo -> String in
            
            return fontInfo.fontName
        }
        
        let aItems = iconAndTitle.map { key -> EventItem in
            
            let name = key
            let iconName = "Font_" + key
            let titleName = NSLocalizedString(key, comment: "title")
            let action: () -> () = {
//                if let aComponent = container!.component as? ITextComponent {
//                
//                if let aDelegate = self.delegate {
//
//                }
                
//                   let size = aComponent.settFontsName(name)
//                    container!.setResize(size, center: CGPointZero, resizeComponent: false, scale: false)
//                }
            }
            let item = EventItem(name: name, iconName: iconName, titleName: titleName, action: action)
            
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
extension FontPannel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return FontsManager.share.getFontsList().count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("fontPannel", forIndexPath: indexPath) as! PannelCell
        
        let item = items[indexPath.item]
        let image = UIImage(named: "Font_LeftAlignment")!
        cell.setImage(image, title: item.titleName)
        cell.updateSelected()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PannelCell {
            cell.updateSelected()
            if let aDelegate = delegate {
                let item = items[indexPath.item]
                let fontName = item.name
                aDelegate.pannelDidSendEvent(.FontNameChanged, object: fontName)
//                item.action(aDelegate.pannelGetContainer())
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
extension FontPannel {
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
