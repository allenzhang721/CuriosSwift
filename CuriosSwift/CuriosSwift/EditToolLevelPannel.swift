//
//  EditToolLevelPannel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class EditToolLevelPannel: EditToolSettingPannel, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var collectionView: UICollectionView!
  var textComponent: TextContentModel!
  let levelKey = ["sendForward", "sendBackward", "lock"]
  var currentLock = false
  var defaultLayout: UICollectionViewFlowLayout {
    
    let top: CGFloat = 10
    let left: CGFloat = 10
    let bottom: CGFloat = 10
    let right: CGFloat = 10
    let itemSpace: CGFloat = 5
    let lineSpace: CGFloat = 5
    let height: CGFloat = bounds.height
    let width: CGFloat = bounds.width
    
    let itemHeight = (height - top - bottom)
    let itemWidth = 1 * itemHeight
    
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    layout.minimumLineSpacing = lineSpace
    layout.minimumInteritemSpacing = itemSpace
    layout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
    return layout
    
  }
  
  override init(aContainerModel: ContainerModel) {
    super.init(aContainerModel: aContainerModel)
    currentLock = aContainerModel.locked
    setupContentView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  deinit {
    println("textFont deinit")
  }
}


// MARK: - Init
extension EditToolLevelPannel {
  
  func setupContentView() {
    
    let layout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "EditToolTextLevelCell")
    collectionView.allowsSelection = true
    
    addSubview(collectionView)
  }
  
  func updateItemLayout() {
    
    collectionView.setCollectionViewLayout(defaultLayout, animated: false)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    begain()
  }
  
  override func begain() {
    
//    let level = levelKey as NSArray
//    let index = alignments.indexOfObject(currentAlignment)
//    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
//    
//    println("index = \(index)")
    
    if currentLock {
      collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.None)
    }
  }
  
  override func updateConstraints() {
    
    collectionView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self)
    }
    
    updateItemLayout()
    super.updateConstraints()
  }
  
}

// MARK: - Delegate & DataSource
extension EditToolLevelPannel {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return levelKey.count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditToolTextLevelCell", forIndexPath: indexPath) as! UICollectionViewCell
    
    let key = levelKey[indexPath.item]
    
    if cell.backgroundView == nil {
      let aKey = (key == "lock") ? "unlock" : key
      let image = UIImage(named: "Typography_\(aKey)")
      let imageView = UIImageView(image: image)
      cell.backgroundView = imageView
    }
    
    if key == "lock" {
      if !(cell.selectedBackgroundView is UIImageView) {
        let image = UIImage(named: "Typography_\(key)")
        cell.selectedBackgroundView = UIImageView(image: image)
      }
    }
    
    cell.layer.cornerRadius = 2
    cell.backgroundColor = UIColor.whiteColor()
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let key = levelKey[indexPath.item]
    if key == "lock" {
      if currentLock {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
      }
      currentLock = !currentLock
      containerModel.locked = currentLock
    }
//    let alignment = levelKey[indexPath.item]
//    currentAlignment = alignment
//    textComponent.setTextAlignment(alignment)
  }
  
//  func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//    
//    let key = levelKey[indexPath.item]
//    if key == "level" {
//      return true
//    } else {
//      return false
//    }
//  }
}