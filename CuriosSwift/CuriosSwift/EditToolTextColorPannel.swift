//
//  EditToolTextColorPannel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import SnapKit

//class EditTextColorPannelCell: UICollectionViewCell {
//  
//  
//}

class EditToolTextColorPannel: EditToolSettingPannel, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var collectionView: UICollectionView!
  var textComponent: TextContentModel!
  var currentColor: String!
  var defaultLayout: UICollectionViewFlowLayout {
    
    let top: CGFloat = 2
    let left: CGFloat = 2
    let bottom: CGFloat = 2
    let right: CGFloat = 2
    let itemSpace: CGFloat = 2
    let lineSpace: CGFloat = 2
    let height: CGFloat = bounds.height
    let width: CGFloat = bounds.width
    
    let itemHeight = (height - top - bottom - itemSpace) / 2.0
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
    currentColor = textComponent.getDemoStringAttributes().color
    setupContentView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  deinit {
    
    println("Color deinit")
  }
}


// MARK: - Init
extension EditToolTextColorPannel {
  
  func setupContentView() {
    
    let layout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "EditToolTextColorCell")
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
    
    let colors = ColorManager.shareInstance.defaultColors as NSArray
    let index = colors.indexOfObject(currentColor)
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
extension EditToolTextColorPannel {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return ColorManager.shareInstance.defaultColors.count
    
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditToolTextColorCell", forIndexPath: indexPath) as! UICollectionViewCell
    
    let color = ColorManager.shareInstance.defaultColors[indexPath.item]
    
    if !(cell.selectedBackgroundView is UIImageView) {
      let image = CuriosKit.imageOfSelectedTick(frame: cell.bounds)
      cell.selectedBackgroundView = UIImageView(image: image)
    }
    
    cell.layer.cornerRadius = 1
    cell.backgroundColor = UIColor(hexString: color)
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let color = ColorManager.shareInstance.defaultColors[indexPath.item]
    currentColor = color
    textComponent.setTextColor(color)
  }
}
