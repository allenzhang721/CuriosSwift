//
//  EditToolAddMaskPannel.swift
//  
//
//  Created by Emiaostein on 9/6/15.
//
//

import UIKit

class EditToolAddMaskPannel: EditToolSettingPannel  {

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
//    textComponent = aContainerModel.component as! TextContentModel
//    currentColor = textComponent.retriveColor()
    setupContentView()
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    begain()
  }
  
  override func begain() {
    
    let colors = ColorManager.shareInstance.defaultColors as NSArray
//    let index = colors.indexOfObject(currentColor)
    
//    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
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
    
    return MasksManager.maskTypes.keys.array.count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditorAddMaskCell", forIndexPath: indexPath) as! UICollectionViewCell
    
//    cell.backgroundColor = UIColor.yellowColor()
    let type = MasksManager.maskTypes.keys.array[indexPath.item]
    if let imageView = cell.backgroundView as? UIImageView {
      MasksManager.imageOfMask(type, AtFrame: cell.bounds, completed: { (image, success) -> () in
        if success {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            imageView.image = image
          })
        }
      })
    } else {
      let imageView = UIImageView(frame: cell.bounds)
      cell.backgroundView = imageView
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
    let type = MasksManager.maskTypes.keys.array[indexPath.item]
//    currentColor = color
//    textComponent.setTextColor(color)
    debugPrint.p("type = \(type)")
    container.setMaskTypeName(type)
  }
  
}
