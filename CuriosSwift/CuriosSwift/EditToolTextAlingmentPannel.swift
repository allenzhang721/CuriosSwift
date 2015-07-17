//
//  EditToolTextAlingmentPannel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class EditToolTextAlignmentPannel: EditToolSettingPannel, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var collectionView: UICollectionView!
  var textComponent: TextContentModel!
  let alignmentKey = ["left", "center", "right"]
  var currentAlignment: String!
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
    textComponent = aContainerModel.component as! TextContentModel
    currentAlignment = textComponent.getDemoStringAttributes().alignment
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
extension EditToolTextAlignmentPannel {
  
  func setupContentView() {
    
    let layout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "EditToolTextAlignmentCell")
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
    
    let alignments = alignmentKey as NSArray
    let index = alignments.indexOfObject(currentAlignment)
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
extension EditToolTextAlignmentPannel {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return alignmentKey.count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditToolTextAlignmentCell", forIndexPath: indexPath) as! UICollectionViewCell
    
    let key = alignmentKey[indexPath.item]
    
    if cell.backgroundView == nil {
      let image = UIImage(named: "Font_\(key)Alignment")
      let imageView = UIImageView(image: image)
      cell.backgroundView = imageView
    }
    
    if !(cell.selectedBackgroundView is UIImageView) {
      let image = UIImage(named: "Editor_Selected")
      cell.selectedBackgroundView = UIImageView(image: image)
    }
    
    cell.layer.cornerRadius = 2
    cell.backgroundColor = UIColor.whiteColor()
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let alignment = alignmentKey[indexPath.item]
    currentAlignment = alignment
    textComponent.setTextAlignment(alignment)
  }
}