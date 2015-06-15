//
//  AnimationPannel.swift
//  
//
//  Created by Emiaostein on 6/12/15.
//
//

import UIKit

struct Item {
    
    let name: String
    let iconName: String
    let titleName: String
    let action: IContainer? -> Void
}

class AnimationPannel: Pannel {
    
    let items: [Item] = {
//        let iconAndTitle = [
//            "FadeIn": "FadeIn",
//            "FloatIn": "FloatIn",
//            "ZoomIn": "ZoomIn",
//            "ScaleIn": "ScaleIn",
//            "DropIn": "DropIn",
//            "SlideIn": "SlideIn",
//            "TeetertotterIn": "TeetertotterIn",
//            "FadeOut": "FadeOut",
//            "FloatOut": "FloatOut",
//            "ZoomOut": "ZoomOut",
//            "ScaleOut": "ScaleOut",
//            "DropOut": "DropOut",
//            "SlideOut": "SlideOut",
//            "TeetertotterOut": "TeetertotterOut"
//        ]
        
        let iconAndTitle = [
            "None",
            "FadeIn",
            "FloatIn",
            "ZoomIn",
            "ScaleIn",
            "DropIn",
            "SlideIn",
            "TeetertotterIn",
            "FadeOut",
            "FloatOut",
            "ZoomOut",
            "ScaleOut",
            "DropOut",
            "SlideOut",
            "TeetertotterOut"
        ]
        
//        let aKeys: [String] = iconAndTitle.keys
        
        let aItems = iconAndTitle.map { key -> Item in
            
            let name = key
            let iconName = "Animation_" + key
            let titleName = NSLocalizedString(key, comment: "title")
            let action: IContainer? -> Void = { container in
                if let aContainer = container {
                    aContainer.setAnimationWithName(name)
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
        collectionView.registerClass(PannelCell.self, forCellWithReuseIdentifier: "animationPannel")
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
            
            let aniName = aContainer.animationName
            var index = 0
            var find = false
            for item in items {
                if item.name == aniName {
                    find = true
                    break
                }
                index++
            }
            if find {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.Left)
            }
        }
    }
}

// MARK: - DataSource and Delegate
// MARK: -
extension AnimationPannel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return items.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("animationPannel", forIndexPath: indexPath) as! PannelCell
        
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
}

// MARK: - IBAction
// MARK: -


// MARK: - Private Method
// MARK: -
extension AnimationPannel {
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
