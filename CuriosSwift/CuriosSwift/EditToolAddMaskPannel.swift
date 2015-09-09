//
//  EditToolAddMaskPannel.swift
//  
//
//  Created by Emiaostein on 9/6/15.
//
//

import UIKit

class EditToolAddMaskPannel: EditToolSettingPannel  {

  let masks = MasksManager.maskTypes.keys.array.sorted(<)
  var collectionView: UICollectionView!
  var currentMask: String!
  var container: ContainerModel!
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
    self.container = aContainerModel
    super.init(aContainerModel: aContainerModel)
    currentMask = aContainerModel.maskType ?? "ANone"
//    textComponent = aContainerModel.component as! TextContentModel
//    currentColor = textComponent.retriveColor()
    setupContentView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    begain()
  }
  
  override func begain() {
    
    let fontNames = masks as NSArray
    let index = fontNames.indexOfObject(currentMask)
    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
  }
}

extension EditToolAddMaskPannel {
  
  func setupContentView() {
    
    let layout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "EditorAddMaskCell")
    collectionView.allowsSelection = true
    collectionView.backgroundColor = UIColor.clearColor()
    
    addSubview(collectionView)
  }
  
  func updateItemLayout() {
    
    collectionView.setCollectionViewLayout(defaultLayout, animated: false)
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
extension EditToolAddMaskPannel: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return masks.count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditorAddMaskCell", forIndexPath: indexPath) as! UICollectionViewCell
    
//    cell.backgroundColor = UIColor.yellowColor()
    if !(cell.selectedBackgroundView is UIImageView) {
      let image = UIImage(named: "Editor_Selected")
      cell.selectedBackgroundView = UIImageView(image: image)
    }
    
    let type = masks[indexPath.item]
    if let imageView = cell.backgroundView?.viewWithTag(1024) as? UIImageView {
      MasksManager.imageOfMask(type, AtFrame: cell.bounds, completed: { (image, success) -> () in
        if success {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            imageView.image = image
          })
        }
      })
    } else {
      cell.layer.borderWidth = 0.5
      cell.layer.borderColor = UIColor.darkGrayColor().CGColor
      cell.layer.cornerRadius = 8
      let view = UIView(frame: CGRectZero)
      cell.backgroundView = view
      let imageView = UIImageView(frame: CGRectInset(cell.bounds, 15, 15))
      imageView.tag = 1024
      imageView.contentMode = .ScaleAspectFit
      cell.backgroundView!.addSubview(imageView)
      MasksManager.imageOfMask(type, AtFrame: cell.bounds, completed: { (image, success) -> () in
        if success {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            imageView.image = image
          })
        }
      })
    }
    
    
    
    
    
    return cell
  }
  
 
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
//    let type = MasksManager.maskTypes.keys.array[indexPath.item]
    let type = masks[indexPath.item]
//    currentColor = color
//    textComponent.setTextColor(color)
    debugPrint.p("type = \(type)")
    container.setMaskTypeName(type)
  }
  
}
