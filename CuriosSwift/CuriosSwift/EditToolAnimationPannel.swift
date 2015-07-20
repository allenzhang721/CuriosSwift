//
//  EditToolAnimationPannel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class EditToolAnimationPannel: EditToolSettingPannel, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var collectionView: UICollectionView!
  var textComponent: TextContentModel!
  var currentAnimation: String!
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
    if aContainerModel.animations.count <= 0 {
      currentAnimation = "None"
    } else {
      currentAnimation = aContainerModel.animations[0].name()
    }
    
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
extension EditToolAnimationPannel {
  
  func setupContentView() {
    
    let layout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "EditToolAnimationCell")
    collectionView.allowsSelection = true
    collectionView.backgroundColor = UIColor.clearColor()
    
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
    
    let animations = AnimationsManager.shareInstance.defautAnimations as NSArray
    let index = animations.indexOfObject(currentAnimation)
    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
    
    println("index = \(index)")
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
extension EditToolAnimationPannel {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return AnimationsManager.shareInstance.defautAnimations.count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditToolAnimationCell", forIndexPath: indexPath) as! UICollectionViewCell
    
    let animation = AnimationsManager.shareInstance.defautAnimations[indexPath.item]
    
    if cell.backgroundView == nil {
      let imageView = UIImageView(frame: cell.bounds)
      cell.backgroundView = imageView
    }
    
    if !(cell.selectedBackgroundView is UIImageView) {
      let image = UIImage(named: "Editor_Selected")
      cell.selectedBackgroundView = UIImageView(image: image)
    }
    
    if let aimageView = cell.backgroundView as? UIImageView {
      let image = UIImage(named: "Animation_\(animation)")
      aimageView.image = image
    }
    
    cell.layer.cornerRadius = 2
    cell.backgroundColor = UIColor.whiteColor()
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let animation = AnimationsManager.shareInstance.defautAnimations[indexPath.item]
    currentAnimation = animation
    containerModel.setAnimationWithName(currentAnimation)
  }
}