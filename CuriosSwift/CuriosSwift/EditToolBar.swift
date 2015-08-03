//
//  EditToolBar.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class EditToolBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
  
  enum EditToolBarType {
    case Default, Image, Text
  }
  
  var contentView: UIView!
  var collectionView: UICollectionView!
  var dataNumber = 4
  var barItems = [String]()
  var currentKey: String!
  weak var delegate: EditToolBarDelegate?
  weak var settingDelegate: EditToolBarSettingDelegate?
  
  var type: EditToolBarType = .Default
  
  var begain: Bool {
    
    return !actived && containerModel != nil
  }
  
  var defaultLayout: UICollectionViewFlowLayout {
    
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
  
    let trail: CGFloat = 10.0
    let leading: CGFloat = 10.0
    let inset = UIEdgeInsets(top: 0, left: leading, bottom:  0, right: trail)
    let itemSideLength: CGFloat = 40
    let width = bounds.width
    
    let number = barItems.count
    
    let lineSpace = number > 2 ? (width - trail - leading - CGFloat(number) * itemSideLength) / CGFloat((number - 1)) : 20
    layout.minimumLineSpacing = lineSpace
    layout.sectionInset = inset
    layout.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
    
    return layout
  }
  
  var actived = false
  var containerModel: ContainerModel?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupContentView()
  }

  required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    setupContentView()
  }
}

// MARK: - Private Method - Init
extension EditToolBar {
  
  private func setupContentView() {
    
    contentView = UIView(frame: CGRectZero)
    
    let layout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "EditToolBarCell")
    collectionView.backgroundColor = UIColor.clearColor()
    addSubview(contentView)
    contentView.addSubview(collectionView)
    
    layer.borderWidth = 0.5
    layer.borderColor = UIColor.lightGrayColor().CGColor
    
    changeToDefault()
  }
  
  private func updateItemLayout() {
    collectionView.setCollectionViewLayout(defaultLayout, animated: false)
  }
}


// MARK: - Public Method
extension EditToolBar {
  
  func updateWithModel(aContainerModel: ContainerModel?) {
    
    if aContainerModel == nil {
      if containerModel == nil && actived == false {
        return
      }
      
      if containerModel != nil && actived == false {
        containerModel = nil
        changeToDefault()
        return
      }
      
      if containerModel != nil && actived == true {
        actived = false
        containerModel = nil
        changeToDefault()
        delegate?.editToolBarDidDeactived(self)
        return
      }
      
    } else {
      if containerModel == nil && actived == false {
        containerModel = aContainerModel
        changedToModel(aContainerModel!)
        delegate?.editToolBar(self, didChangedToContainerModel: aContainerModel!)
        return
      }
      
      if containerModel != nil && actived == false {
        if containerModel != aContainerModel! {
          containerModel = aContainerModel
          changedToModel(aContainerModel!)
          delegate?.editToolBar(self, didChangedToContainerModel: aContainerModel!)
        }
        return
      }
      
      if containerModel != nil && actived == true {
        if containerModel != aContainerModel {
          
          let same = containerModel?.component.type == aContainerModel?.component.type

          containerModel = aContainerModel
          changedToModel(aContainerModel!)
          
          if !same && !(currentKey == "level" || currentKey == "animation") {
            currentKey = barItems[0]
            
          }
          
          let keys = barItems as NSArray
          let index = keys.indexOfObject(currentKey)
          
          collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.None)
          
          performSelectorWithKey(currentKey)
          
          delegate?.editToolBar(self, didChangedToContainerModel: aContainerModel!)
        }
        return
      }
    }
  }
  
  private func changeToDefault() {
    
    type = .Default
    barItems = ["setting", "addImage", "addText", "preView"]
    collectionView.reloadData()
    updateItemLayout()
  }
  
  private func changedToModel(aContainerModel: ContainerModel) {
    
    switch aContainerModel.component {
      
    case let component as TextContentModel:
      type = .Text
      barItems = ["textFont", "textColor", "textAlignment", "animation", "level"]
      
      
    case let component as ImageContentModel:
      type = .Image
      barItems = [ "animation", "level"]
      
      
    default:
      changeToDefault()
      
    }
    
    collectionView.reloadData()
    updateItemLayout()
    // nil - setting \ add Image \ add Text \ Preview
    
    
    // image - level \ animation
    
    
    // text - fontName \ alignment \ color \ level \ animation
  }
  
  private func performSelectorWithKey(key: String) {
    
    switch key {
      
    case "setting":
      setting()
    case "addImage":
      addImage()
      case "addText":
      addText()
      case "preView":
      preView()
      case "textFont":
      textFont()
      case "textAlignment":
      textAlignment()
      case "textColor":
      textColor()
      case "level":
      level()
      case "animation":
      animation()
      
    default:
      return
    }
    
  }
}

// MARK: - private method - delegate method
extension EditToolBar {
  
  func setting() {
    delegate?.editToolBarDidSelectedSetting(self)
  }
  
  func addImage() {
    delegate?.editToolBarDidSelectedAddImage(self)
    
  }
  
  func addText() {
    delegate?.editToolBarDidSelectedAddText(self)
  }
  
  func preView() {
    delegate?.editToolBarDidSelectedPreview(self)
  }
  
  func level() {
    settingDelegate?.editToolBar(self, didSelectedLevel: containerModel!)
  }
  
  func animation() {
    settingDelegate?.editToolBar(self, didSelectedAnimation: containerModel!)
  }
  
  func textFont() {
    settingDelegate?.editToolBar(self, didSelectedTextFont: containerModel!)
  }
  
  func textAlignment() {
    settingDelegate?.editToolBar(self, didSelectedTextAlignment: containerModel!)
  }
  
  func textColor() {
    settingDelegate?.editToolBar(self, didSelectedTextColor: containerModel!)
  }
}


// MARK: - private Mehtod - BarItems
extension EditToolBar {
  
}










// MARK: - Private Method - Constraint
extension EditToolBar {
  
  override func updateConstraints() {
    
    contentView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self)
    }
    
    collectionView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self)
    }

    super.updateConstraints()
    
    updateItemLayout()
  }
}













// MARK: - DataSource & Delegate
extension EditToolBar {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return barItems.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditToolBarCell", forIndexPath: indexPath) as! UICollectionViewCell
    
    
    if cell.backgroundView == nil {
      let aView = UIView()
      let imageView = UIImageView(frame: CGRectInset(cell.bounds, cell.bounds.height * 0.25, cell.bounds.height * 0.25))
      imageView.contentMode = .ScaleAspectFit
      aView.addSubview(imageView)
       cell.backgroundView = aView
    }
    
    if cell.selectedBackgroundView == nil {
      let aView = UIView()
      let imageView = UIImageView(frame: CGRectInset(cell.bounds, cell.bounds.height * 0.25, cell.bounds.height * 0.25))
      imageView.contentMode = .ScaleAspectFit
      cell.selectedBackgroundView = aView
      cell.selectedBackgroundView.addSubview(imageView)
    }
    
    if let imageView = cell.backgroundView?.subviews[0] as? UIImageView {
      let key = barItems[indexPath.item]
      let image = UIImage(named: "Editor_\(key)_Normal")
      imageView.image = image
    }
    
    if let selectedImageView = cell.selectedBackgroundView.subviews[0] as? UIImageView {
      let key = barItems[indexPath.item]
      let image = UIImage(named: "Editor_\(key)_Selected")
      selectedImageView.image = image
    }
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    if actived == false && containerModel != nil {
      actived = true
//      collectionView.reloadData()
      delegate?.editToolBar(self, activedWithContainerModel: containerModel!)
    }
    
    let key = barItems[indexPath.item]
    currentKey = key
    performSelectorWithKey(key)
  }
  
}

