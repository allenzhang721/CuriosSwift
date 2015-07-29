//
//  EditToolTextFontPannel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import UIKit

class EditToolTextFontPannel: EditToolSettingPannel, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var collectionView: UICollectionView!
  var textComponent: TextContentModel!
  var currentFont: String!
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
    currentFont = textComponent.getDemoStringAttributes().fontName
    setupContentView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


// MARK: - Init
extension EditToolTextFontPannel {
  
  func setupContentView() {
    
    let layout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "EditToolTextFontCell")
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
  
    let fontNames = FontsManager.share.getFontNameList() as NSArray
    let index = fontNames.indexOfObject(currentFont)
    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
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
extension EditToolTextFontPannel {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return FontsManager.share.getFontsList().count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditToolTextFontCell", forIndexPath: indexPath) as! UICollectionViewCell
    
    let textFont = FontsManager.share.getFontsList()[indexPath.item].fontName
    
    if cell.backgroundView == nil {
      let label = UILabel(frame: bounds)
      label.text = "字"
      label.textAlignment = .Center
      cell.backgroundView = label
    }
    
    if !(cell.selectedBackgroundView is UIImageView) {
      let image = UIImage(named: "Editor_Selected")
      cell.selectedBackgroundView = UIImageView(image: image)
    }
    
    if let aLabel = cell.backgroundView as? UILabel {
      aLabel.font = UIFont(name: textFont, size: 40)
    }
    
    cell.layer.cornerRadius = 8
    cell.layer.borderWidth = 0.5
    cell.layer.borderColor = UIColor.lightGrayColor().CGColor
    cell.backgroundColor = UIColor.whiteColor()
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let fontName = FontsManager.share.getFontsList()[indexPath.item].fontName
    currentFont = fontName
    if textComponent.setFontName(fontName) {
      containerModel.needUpdateOnScreenSize(true)
    }
    
  }
}