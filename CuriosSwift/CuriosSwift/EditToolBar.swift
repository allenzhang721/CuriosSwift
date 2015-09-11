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
  
//  private enum State {
//    case Normal
//    case Image(Bool, String?) //selected, key
//    case Text(Bool, String?)
//  }
  
//  private var previousState: State = .Normal
//  private var currentState: State = .Normal {
//    
//    willSet {
//      stateWillChanged(previousState, after: newValue, beforeContainer: containerModel, afterContainer: containerModel)
//      previousState = currentState
//    }
//    
//    didSet {
//      
//    }
//  }
  
  private var containerModel: ContainerModel?
    
//    willSet {
//      stateWillChanged(currentState, after: currentState, beforeContainer: containerModel, afterContainer: newValue)
//    }
  
//  private var didActived: Bool {
//    
//    switch currentState {
//    case .Normal:
//      return false
//    default:
//      return true
//    }
//  }
//  
//  private var previousItems: [String] {
//    
//    switch previousState {
//    case .Normal:
//      return ["setting", "addImage", "addText", "preView"]
//    case .Image(let selected, let key):
//      return [ "animation", "level"]
//    case .Text(let selected, let key):
//      return ["textFont", "textColor", "textAlignment", "animation", "level"]
//    default:
//      return ["setting", "addImage", "addText", "preView"]
//    }
//  }
  
  
  
  
  var contentView: UIView!
  var collectionView: UICollectionView!
  var cancelButton: UIButton!
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
//    let lineSpace: CGFloat = 20
    layout.minimumLineSpacing = lineSpace
    layout.sectionInset = inset
    layout.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
    
    return layout
  }
  
  var showHiddenLayout: UICollectionViewFlowLayout {
    
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    
    let trail: CGFloat = 10.0
    let leading: CGFloat = 10.0
    let inset = UIEdgeInsets(top: 0, left: leading, bottom:  0, right: trail)
    let itemSideLength: CGFloat = 40
    let width = collectionView.bounds.width
    
    let number = barItems.count
    
//    let lineSpace = number > 2 ? (width - trail - leading - CGFloat(number) * itemSideLength) / CGFloat((number - 1)) : 20
        let lineSpace: CGFloat = (width - trail - leading - 4 * itemSideLength) / 4
    layout.minimumLineSpacing = lineSpace
    layout.sectionInset = inset
    layout.itemSize = CGSize(width: itemSideLength, height: itemSideLength)
    
    return layout
  }
  
  var actived = false
  
  
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
    
    contentView = UIView(frame: bounds)
    
    let layout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "EditToolBarCell")
    collectionView.backgroundColor = UIColor.clearColor()
    addSubview(contentView)
    contentView.addSubview(collectionView)
    
    //editButton
    cancelButton = UIButton.buttonWithType(.Custom) as! UIButton
    cancelButton.frame = CGRect(x: bounds.width, y: 0, width: 44, height: bounds.height)
    cancelButton.backgroundColor = UIColor.lightGrayColor()
    cancelButton.setImage(UIImage(named: "ToolBar_Cancel"), forState: UIControlState.Normal)
    cancelButton.addTarget(self, action: "cancelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(cancelButton)
    
    layer.borderWidth = 0.5
    layer.borderColor = UIColor.lightGrayColor().CGColor
    
    setupConstraints()
    
    changeToDefault()
  }
  
  func cancelButtonAction(sender: UIButton) {
    
    delegate?.editToolBarDidSelectedCancel(self)
    
  }
  
  private func updateItemLayout() {
    collectionView.setCollectionViewLayout(defaultLayout, animated: false)
  }
  
  private func updateItemActiveLayout() {
    collectionView.setCollectionViewLayout(showHiddenLayout, animated: false)
  }
  
  private func setupConstraints() {
    
    let width = bounds.width
    let cancelButtonWidth = 44
    
    contentView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self)
    }
    
    collectionView.snp_makeConstraints { (make) -> Void in
      make.top.bottom.left.equalTo(self)
      make.width.equalTo(width)
    }
    
    cancelButton.snp_makeConstraints({ (make) -> Void in
      make.width.equalTo(cancelButtonWidth)
      make.top.bottom.equalTo(self)
      make.right.equalTo(self).offset(cancelButtonWidth)
    })
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
        setNeedsUpdateConstraints()

        return
      }
      
      if containerModel != nil && actived == true {
        actived = false
        containerModel = nil
        changeToDefault()

        delegate?.editToolBarDidDeactived(self)
        setNeedsUpdateConstraints()
        return
      }
      
    } else {
      if containerModel == nil && actived == false {
        containerModel = aContainerModel
        changedToModel(aContainerModel!)

        delegate?.editToolBar(self, didChangedToContainerModel: aContainerModel!)
        setNeedsUpdateConstraints()
        return
      }
      
      if containerModel != nil && actived == false {
        if containerModel != aContainerModel! {
          containerModel = aContainerModel
          changedToModel(aContainerModel!)
//          updateConstraintsWithState()
          delegate?.editToolBar(self, didChangedToContainerModel: aContainerModel!)
          setNeedsUpdateConstraints()
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
//          updateConstraintsWithState()
          delegate?.editToolBar(self, didChangedToContainerModel: aContainerModel!)
          setNeedsUpdateConstraints()
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
      collectionView.reloadData()
      updateItemActiveLayout()
      
    case let component as ImageContentModel:
      type = .Image
      barItems = ["Mask", "animation", "level"]
//      barItems = ["animation", "level"]
      
      collectionView.reloadData()
      updateItemActiveLayout()
      
    default:
      changeToDefault()
      
    }
    
//    collectionView.reloadData()
//    updateItemActiveLayout()
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
      
      case "Mask":
      addMask()
      
    default:
      return
    }
    
  }
}



// MARK: - 状态切换
extension EditToolBar {
  
//  private func stateWillChanged(before: State, after: State, beforeContainer: ContainerModel?, afterContainer: ContainerModel?) {
//    
//    
//    if afterContainer == nil {
//      // cancel
//      
//      switch before {
//      case .Normal:
//        // 1
//        switch after {
//        case .Normal:
//          ()
//        case .Image(let aselected, let akey):
//          // updateConstraints
//          delegate?.editToolBarDidDeactived(self)
//        case .Text(let aselected, let akey):
//          // updateConstraints
//          delegate?.editToolBarDidDeactived(self)
//        default:
//          ()
//        }
//        
//      case .Image(let bselected, let bkey):
//        
//        // 2
//        switch after {
//        case .Normal:
//          delegate?.editToolBarDidDeactived(self)
//        case .Image(let aselected, let akey):
//          ()
//        case .Text(let aselected, let akey):
//          ()
//        default:
//          ()
//          
//        }
//        
//      case .Text(let bselected, let bkey):
//        
//        // 3
//        switch after {
//          
//        case .Normal:
//          delegate?.editToolBarDidDeactived(self)
//        case .Image(let aselected, let akey):
//          ()
//        case .Text(let aselected, let akey):
//          ()
//          
//        default:
//          ()
//        }
//        
//      default:
//        ()
//        
//      }
//    } else {
//      
//      // different
//      switch before {
//      case .Normal:
//        // 1
//        switch after {
//        case .Normal:
//          ()
//        case .Image(let aselected, let akey):
//          delegate?.editToolBar(self, activedWithContainerModel: containerModel!)
//          if let akey = akey {
//            performSelectorWithKey(akey)
//          }
//        case .Text(let aselected, let akey):
//          delegate?.editToolBar(self, activedWithContainerModel: containerModel!)
//          if let akey = akey {
//            performSelectorWithKey(akey)
//          }
//        default:
//          ()
//        }
//        
//      case .Image(let bselected, let bkey):
//        
//        // 2
//        switch after {
//        case .Normal:
//          ()
//        case .Image(let aselected, let akey):
//          if  beforeContainer != afterContainer {
//            
//          }
//          
//        case .Text(let aselected, let akey):
//          ()
//          
//        default:
//          ()
//          
//        }
//        
//      case .Text(let bselected, let bkey):
//        
//        // 3
//        switch after {
//          
//        case .Normal:
//          ()
//        case .Image(let aselected, let akey):
//          ()
//          
//        case .Text(let aselected, let akey):
//          ()
//          
//        default:
//          ()
//        }
//        
//      default:
//        ()
//        
//      }
//      
//    }
//  }
  
  
  private func updateConstraintsWithState() {
    
    func showCancelButton() {
      let buttonWidth = cancelButton.bounds.width
      let width = bounds.width
      cancelButton.snp_updateConstraints({ (make) -> Void in
        make.right.equalTo(self)
      })
      
      let cancelleft = cancelButton.snp_left
      collectionView.snp_updateConstraints({ (make) -> Void in
        make.width.equalTo(width - buttonWidth)
      })
      
      layoutIfNeeded()
//        collectionView.setCollectionViewLayout(showHiddenLayout, animated: false)
//      UIView.animateWithDuration(0.2, animations: { () -> Void in
//        self.layoutIfNeeded()
//      })
      updateItemActiveLayout()
    }
    
    func hiddenCancelButton() {
      let buttonWidth = cancelButton.bounds.width
      let width = bounds.width
      collectionView.snp_updateConstraints { (make) -> Void in
        make.width.equalTo(width)
      }
      cancelButton.snp_updateConstraints({ (make) -> Void in
        make.width.equalTo(buttonWidth)
        make.right.equalTo(self).offset(buttonWidth)
      })
      
      layoutIfNeeded()
//        collectionView.setCollectionViewLayout(defaultLayout, animated: false)
//      UIView.animateWithDuration(0.2, animations: { () -> Void in
//        self.layoutIfNeeded()
//      })
      updateItemLayout()
    }
    
    if containerModel != nil {
      showCancelButton()
      
    }else {
      hiddenCancelButton()
    }
    
//    UIView.animateWithDuration(0.2, animations: { () -> Void in
//      self.layoutIfNeeded()
//    })
    
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
  
  func addMask() {
    settingDelegate?.editToolBar(self, didSelectedAddMask: containerModel!)
  }
}


// MARK: - private Mehtod - BarItems
extension EditToolBar {
  
}










// MARK: - Private Method - Constraint
extension EditToolBar {
  
  override func updateConstraints() {

//    if didActived {
//      let buttonWidth = cancelButton.bounds.width
//      let width = bounds.width
//      collectionView.snp_updateConstraints({ (make) -> Void in
//        make.width.equalTo(width - buttonWidth)
//      })
////      
//      cancelButton.snp_makeConstraints({ (make) -> Void in
//        make.right.equalTo(self)
//      })
//      
//    } else {
//      collectionView.snp_makeConstraints { (make) -> Void in
//        make.width.equalTo(self)
//      }
//      cancelButton.snp_makeConstraints({ (make) -> Void in
//        make.left.equalTo(self.snp_right)
//      })
//    }
    
    updateConstraintsWithState()
    
    super.updateConstraints()
    
//    updateItemLayout()
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
    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
    
    if actived == false && containerModel != nil {
      actived = true
//      collectionView.reloadData()
//      updateConstraintsWithState()
      delegate?.editToolBar(self, activedWithContainerModel: containerModel!)
    }
    
    let key = barItems[indexPath.item]
    currentKey = key
    performSelectorWithKey(key)
  }
    
  
}

