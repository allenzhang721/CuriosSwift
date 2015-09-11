//
//  SmallLayout.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/18/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol SmallLayoutDelegate: NSObjectProtocol {
  
  func layout(layout: smallLayout, begainSelectedItemAtIndexPath indexPath: NSIndexPath)
  func layout(layout: smallLayout, willInsertSelectedItemAtIndexPath indexPath: NSIndexPath)
  func layout(layout: smallLayout, willMovedItemAtIndexPath FromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
  func layout(layout: smallLayout, willDeletedItemAtIndexPath indexPath: NSIndexPath)
  func layoutDidEndSelected(layout: smallLayout)
  
  
  
  
//  func layout(layout: UICollectionViewLayout, willMoveInAtIndexPath indexPath: NSIndexPath)
//  func layout(layout: UICollectionViewLayout, willMoveOutFromIndexPath indexPath: NSIndexPath)
//  func layout(layout: UICollectionViewLayout, willChangeFromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
//  func layoutDidMoveIn(layout: UICollectionViewLayout, didMoveInAtIndexPath indexPath: NSIndexPath)
//  func layoutDidMoveOut(layout: UICollectionViewLayout)
//  func layout(layout: UICollectionViewLayout, didFinished finished: Bool)
}

//MARK: - SmallLayout

class smallLayout: UICollectionViewFlowLayout {
  
  enum AutoScrollDirection {
    case Stay, Top, End
  }
  
  let defaultSelectedIndexPath = NSIndexPath(forItem: -1, inSection: 0)
  var placeholderIndexPath: NSIndexPath = NSIndexPath(forItem: -1, inSection: 0)
  var isDefaultSelectedIndexPath: Bool {
    return isSameIndexPath(placeholderIndexPath, rhs: defaultSelectedIndexPath)
  }
  
  var onContentCenter = CGPointZero
  
  

  weak var delegate: SmallLayoutDelegate?
  private var reordering = false
  private var pointMoveIn = false
  private var fakeCellCenter = CGPointZero
  private var autoScrollDirection: AutoScrollDirection = .Stay
  private var displayLink: CADisplayLink?
  
  var allowChangedItem = true
  
  let minScale = floor(LayoutSpec.layoutConstants.smallLayout.shrinkScale * 1000)/1000.0
  
  override init() {
    super.init()
    setuoProperties()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setuoProperties()
  }
  
  private func setuoProperties() {
    itemSize = LayoutSpec.layoutConstants.smallLayout.itemSize
    sectionInset = LayoutSpec.layoutConstants.smallLayout.sectionInsets
    scrollDirection = .Horizontal
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
  func isSameIndexPath(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    
    let result = lhs.compare(rhs)
    switch result {
    case .OrderedSame:
      return true
    default:
      return false
    }
  }

  
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    
    let attribute = super.layoutAttributesForItemAtIndexPath(indexPath)
    
    if isSameIndexPath(placeholderIndexPath, rhs:indexPath) {
//      attribute.alpha = 0
      attribute.hidden = true
    } else {
//      attribute.alpha = 1
      attribute.hidden = false
    }
    
    return attribute
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    
    let att = super.layoutAttributesForElementsInRect(rect)
    if let attributes = att {
      for attribute in attributes as! [UICollectionViewLayoutAttributes] {
        
//        if let cell = collectionView?.cellForItemAtIndexPath(attribute.indexPath) as? PageCollectionViewCell {
//          debugPrint.p("attributescount = \(attributes.count) \n layout Cell minScale = \(minScale)")
//          cell.scale = minScale
//          cell.update()
//        } else {
//          debugPrint.p("not pageCell")
//        }
        
        if isSameIndexPath(placeholderIndexPath, rhs: attribute.indexPath) {
//           attribute.alpha = 0
          attribute.hidden = true
          
        } else {
//           attribute.alpha = 1
          attribute.hidden = false
        }
    }
  }
    return att
  }
  
  // MARK: - Public Method
  // MARK: -
  
  func begainSelectedAtOnScreenPoint(pointOnCollectionViewContent point: CGPoint) -> Bool {
//    let virtualY = point.y
//    let virtualX = point.x - collectionView!.contentOffset.x +
//
//    let aPoint = CGPoint(x: virtualX, y: virtualY)
    if let selectedIndexPath = getIndexPathWithPoint(pointOnCollectionContent: point) {
      onContentCenter = point
      placeholderIndexPath = NSIndexPath(forItem: selectedIndexPath.item, inSection: selectedIndexPath.section)
      delegate?.layout(self, begainSelectedItemAtIndexPath: placeholderIndexPath)
      return true
    } else {
      return false
    }
  }
  
  func begainInsertSelectedAtOnScreenPoint(pointOnCollectionViewContent point: CGPoint) {
    
    let virtualY = sectionInset.top + itemSize.height / 2.0
//    let virtualX = collectionView!.contentOffset.x + point.x
    onContentCenter = CGPoint(x: point.x, y: virtualY)
//    let aPoint = CGPoint(x: virtualX, y: virtualY)
    let insertedIndexPath = getInsertedIndexpathWithPoint(pointOnCollectionContent: onContentCenter)
    placeholderIndexPath = insertedIndexPath
    delegate?.layout(self, willInsertSelectedItemAtIndexPath: placeholderIndexPath)
  }
  
  func changedOnScreenPointTransition(pointOnCollectionContent translation: CGPoint) {
    onContentCenter.x += translation.x
    if !autoScrollIfNeed(onBoundsPoint: onContentCenter) {
      changeItemsIfNeed(pointOnContent: onContentCenter)
    }
    
  }
  
  
  func endSelected(deleted: Bool) {
    
    if isDefaultSelectedIndexPath {
      return
    }
    
    if deleted {
      delegate?.layout(self, willDeletedItemAtIndexPath: placeholderIndexPath)
    }
    onContentCenter = CGPointZero
    placeholderIndexPath = defaultSelectedIndexPath
    delegate?.layoutDidEndSelected(self)
  }
  
  func getIndexPathWithPoint(pointOnCollectionContent point: CGPoint) -> NSIndexPath? {
    
    return getIndexPathWithPoint(point, isOnBounds: false, ignoreY: false, needCreateNewIndexPath: false)
  }
  
  func getInsertedIndexpathWithPoint(pointOnCollectionContent point: CGPoint) -> NSIndexPath! {
    
    return getIndexPathWithPoint(point, isOnBounds: false, ignoreY: true, needCreateNewIndexPath: true)!
  }
  
  
  func getIndexPathWithPoint(point: CGPoint, isOnBounds: Bool, ignoreY: Bool, needCreateNewIndexPath: Bool) -> NSIndexPath? {
    
    let y = ignoreY ? sectionInset.top + itemSize.height / 2.0 : point.y
    let x = isOnBounds ? collectionView!.contentOffset.x + point.x : point.x
    let responsePoint = CGPoint(x: x, y: y)
    
    // real indexPath at point
    if !ignoreY && !needCreateNewIndexPath {
      return collectionView?.indexPathForItemAtPoint(responsePoint)
    }
    
//    let left = sectionInset.left
//    let right = sectionInset.right
    let count = collectionView!.numberOfItemsInSection(0)
    
    // get insert indexPath
    if ignoreY && needCreateNewIndexPath {
      
      // no cells
      if count <= 0 {
        return NSIndexPath(forItem: 0, inSection: 0)
      } else {
        
        if count == 1 {
          return NSIndexPath(forItem: count, inSection: 0)
        }
        
        let firstX = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)).center.x
        let lastX = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: count - 1, inSection: 0)).center.x
        
        // last
        if x > lastX {
          return NSIndexPath(forItem: count, inSection: 0)
        }
        
        // first
        if x < firstX {
          return NSIndexPath(forItem: 0, inSection: 0)
        }

        // middle
        let rect = CGRect(x: collectionView!.contentOffset.x, y: 0, width: collectionView!.bounds.width, height: collectionView!.bounds.height)
        let visualCells = collectionView!.visibleCells() as! [UICollectionViewCell]
        let nearestCell = visualCells.filter { $0.center.x < x }.last!
        let nearestIndexPath = collectionView!.indexPathForCell(nearestCell)!
        return NSIndexPath(forItem: nearestIndexPath.item + 1, inSection: 0)
      }
    }
    
    return nil
  }
  
  
  
  
  
  
  
  
//  private func getIndexPathByPointInBounds(point: CGPoint) -> NSIndexPath {
//    let contentSize = collectionView?.contentSize
//    let leftEdge = sectionInset.left
//    let rigthEdge = contentSize!.width - sectionInset.right
//    let visualCells = collectionView?.visibleCells()
//    let x = point.x
//    var placeHolderIndexpath = NSIndexPath(forItem: 0, inSection: 0)
//    
//    if visualCells?.count > 0 {
//      
//      switch x {
//      case let x where x < leftEdge:
//        placeholderIndexPath = NSIndexPath(forItem: 0, inSection: 0)
//      case let x where x > rigthEdge:
//        let lastCell = visualCells?.last as! UICollectionViewCell
//        let lastIndexPath = collectionView?.indexPathForCell(lastCell)
//        placeholderIndexPath = NSIndexPath(forItem: lastIndexPath!.item + 1, inSection: 0)
//        
//      default:
//        var find = false
//        for cell in visualCells as! [UICollectionViewCell] {
//          if cell.center.x > x {
//            find = true
//            placeholderIndexPath = collectionView?.indexPathForCell(cell)
//            break
//          }
//        }
//        
//        if find == false {
//          let lastCell = visualCells?.last as! UICollectionViewCell
//          let lastIndexPath = collectionView?.indexPathForCell(lastCell)
//          placeholderIndexPath = NSIndexPath(forItem: lastIndexPath!.item + 1, inSection: 0)
//        }
//      }
//    } else {
//      placeholderIndexPath = NSIndexPath(forItem: 0, inSection: 0)
//    }
//    
//    return placeholderIndexPath!
//  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // When Gesture Began
//  func selectedItemBeganAtLocation(point: CGPoint) -> Bool {
//    
//    if let indexPath = collectionView?.indexPathForItemAtPoint(point) {
//      placeholderIndexPath = indexPath
//      reordering = true
//      collectionView?.performBatchUpdates({ () -> Void in
//        }, completion: { (completion) -> Void in
//      })
//      return true
//    } else {
//      reordering = false
//      return false
//    }
//  }
  
  func getSelectedItemSnapShot() -> UIView? {
    if !isDefaultSelectedIndexPath {
      let cell = collectionView?.cellForItemAtIndexPath(placeholderIndexPath)
      return cell?.snapshotViewAfterScreenUpdates(false)
    } else {
      return nil
    }
  }
  
  // When Gesture changed
//  func selectedItem(moveIn: Bool, AtLocation point: CGPoint) {
//    if moveIn {
//      if !pointMoveIn {
//        pointMoveIn = true
//        responseToPointMoveIn(point)
//      }
//      
//      responseToPointMove(point)
//      
//    } else { // move out or out of here
//      if pointMoveIn {
//        pointMoveIn = false
//        responseToPointWillMoveOut()
//      }
//    }
//  }
  
  // When Gesture End
//  func selectedItemMoveFinishAtLocation(point: CGPoint, fromeTemplate: Bool) {
//    
//    if let aPlaceholderIndexPath = placeholderIndexPath {
//      if fromeTemplate {
//        if !CGRectContainsPoint(collectionView!.bounds, point) {
//          delegate?.layoutDidMoveIn(self, didMoveInAtIndexPath: aPlaceholderIndexPath)
//        }
//      }
//      
//    } else {
//      if !fromeTemplate {
//        delegate?.layoutDidMoveOut(self)
//      }
//    }
////    collectionView?.performBatchUpdates({ () -> Void in
////      }, completion: nil)
//    
//    delegate?.layout(self, didFinished: true)
//    
//    collectionView?.scrollsToTop = true
//    fakeCellCenter = CGPointZero
//    placeholderIndexPath = nil
//    pointMoveIn = false
//    reordering = false
//    invalidateDisplayLink()
//    invalidateLayout()
//    
//  }
}


// MARK: - Private Method
// MARK: - Items Modify
extension smallLayout {
  
  // Whten Gesture Move
//  private func responseToPointMove(point: CGPoint) {
//    if placeholderIndexPath == nil {
//      return
//    }
//    fakeCellCenter = point
//    autoScrollIfNeed(fakeCellCenter)
//    changeItemIfNeed()
//    
//  }
  
  // move in
//  private func responseToPointMoveIn(point: CGPoint) {
//    if placeholderIndexPath == nil {
//      placeholderIndexPath = getIndexPathByPointInBounds(point)
//      
//      if let aPlaceHolderIndexPath = placeholderIndexPath {
//        placeholderIndexPath = getIndexPathByPointInBounds(point)
//        fakeCellCenter = point
//        if let aDelegate = delegate {
//          
//          // will move in delegate
//          aDelegate.layout(self, willMoveInAtIndexPath: aPlaceHolderIndexPath)
//          collectionView?.performBatchUpdates({ () -> Void in
//            
//            self.collectionView?.insertItemsAtIndexPaths([aPlaceHolderIndexPath])
//            
//            }, completion: { (completed) -> Void in
//          })
//        }
//      }
//    }
//  }
  
  
  // move out
//  func responseToPointWillMoveOut() {
//
//    if let aPlacehoderIndexPath = placeholderIndexPath {
//      self.delegate?.layout(self, willMoveOutFromIndexPath: aPlacehoderIndexPath)
    
      
//      collectionView?.performBatchUpdates({ () -> Void in
//        self.collectionView?.deleteItemsAtIndexPaths([aPlacehoderIndexPath])
//        }, completion: { [unowned self] (completed) -> Void in
//          
//          if completed {
//          }
      
//          self.fakeCellCenter = CGPointZero
//          self.placeholderIndexPath = nil
//          self.pointMoveIn = false
//          self.invalidateDisplayLink()
//          self.invalidateLayout()
//          self.collectionView?.performBatchUpdates({ () -> Void in
//            }, completion: nil)
//        })
      
//      collectionView?.scrollsToTop = true
//      fakeCellCenter = CGPointZero
//      placeholderIndexPath = nil
//      pointMoveIn = false
//      reordering = false
//      invalidateDisplayLink()
//      invalidateLayout()
//    }
//  }
  
  private func changeItemsIfNeed(pointOnContent point: CGPoint) {
  
    if !allowChangedItem {
      return
    }
    
    if isDefaultSelectedIndexPath {
      return
    }
    
    let indexPath = getIndexPathWithPoint(pointOnCollectionContent: point)
    
    if indexPath == nil {
      return
    }
    
    if !isSameIndexPath(placeholderIndexPath, rhs: indexPath!) {
      allowChangedItem = false
      let current = NSIndexPath(forItem: placeholderIndexPath.item, inSection: placeholderIndexPath.section)
      placeholderIndexPath = indexPath!
      delegate?.layout(self, willMovedItemAtIndexPath: current, toIndexPath: indexPath!)
      
    }
    
  }
  
  
//  private func changeItemIfNeed() {
//    var fromIndexPath: NSIndexPath?
//    var toIndexPath: NSIndexPath?
//    if let aPlaceholderIndexPath = placeholderIndexPath {
//      fromIndexPath = aPlaceholderIndexPath
//      toIndexPath = collectionView?.indexPathForItemAtPoint(fakeCellCenter)
//    }
//    if fromIndexPath == nil || toIndexPath == nil {
//      return
//    }
//    if fromIndexPath == toIndexPath {
//      return
//    }
//    
//    //TODO: delegate can move item
//    //...
//    
//    self.delegate?.layout(self, willChangeFromIndexPath: fromIndexPath!, toIndexPath: toIndexPath!)
//    self.placeholderIndexPath = toIndexPath
////    collectionView?.performBatchUpdates({ [unowned self] () -> Void in
////      
////      self.collectionView?.moveItemAtIndexPath(fromIndexPath!, toIndexPath: toIndexPath!)
////      }, completion: nil)
//  }
}

// MARK: - AutoScroll
extension smallLayout {
  
  private func autoScrollIfNeed(onBoundsPoint point: CGPoint) -> Bool {
    let offset = collectionView!.contentOffset
    let triggerInsetTop: CGFloat = 50.0
    let triggerInsetEnd: CGFloat = 50.0
    let boundsLength = CGRectGetWidth(collectionView!.bounds)
    let contentLength = collectionView!.contentSize.width
    switch point.x {
    case let x where offset.x > 0 && x <= offset.x + triggerInsetTop:
      autoScrollDirection = .Top
      setupDisplayLink()
      return true
    case let x where offset.x <= contentLength - boundsLength && x >= offset.x + boundsLength - triggerInsetEnd:
      autoScrollDirection = .End
      setupDisplayLink()
      return true
    default:
      invalidateDisplayLink()
      changeItemsIfNeed(pointOnContent: onContentCenter)
      return false
    }
  }
  
  private func invalidateDisplayLink() {
    autoScrollDirection = .Stay
    displayLink?.invalidate()
    displayLink = nil
    
  }
  
  private func setupDisplayLink() {
    if displayLink != nil {
      return
    }
    displayLink = CADisplayLink(target: self, selector: "continueScrollIfNeed")
    displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }
  
  func continueScrollIfNeed() {
    if isDefaultSelectedIndexPath {
      return
    }
    let percentage: CGFloat = 0.5
    var scrollRate = calcscrollRateIfNeedWithSpeed(10.0, percentage: percentage)
    let offsetTop = collectionView!.contentOffset.x
    let insetTop: CGFloat = sectionInset.left
    let insetEnd: CGFloat = sectionInset.right
    let length = CGRectGetWidth(collectionView!.bounds)
    let contentLength = collectionView!.contentSize.width
    if contentLength + insetTop + insetEnd <= length {
      return
    }
    
    if offsetTop + scrollRate <= -insetTop {
      scrollRate = -insetTop - offsetTop
    } else if offsetTop + scrollRate >= contentLength + insetEnd - length {
      scrollRate = contentLength + insetEnd - length - offsetTop
    }
    
//            collectionView?.performBatchUpdates({ [unowned self] () -> Void in
//    self.fakeCellCenter.x += scrollRate
    
    let contentOffset = CGPoint(x: self.collectionView!.contentOffset.x + scrollRate / 2.0, y: self.collectionView!.contentOffset.y)
    self.collectionView?.contentOffset = contentOffset
    changeItemsIfNeed(pointOnContent: onContentCenter)
    onContentCenter.x += scrollRate / 2.0
    autoScrollIfNeed(onBoundsPoint: onContentCenter)
    //        changeItemIfNeed()
//                }, completion: nil)
  }
  
  private func calcscrollRateIfNeedWithSpeed(speed: CGFloat, percentage: CGFloat) -> CGFloat {
    if isDefaultSelectedIndexPath {
      return 0.0
    }
    func scrollRate(value: CGFloat) -> CGFloat {
      return value * max(0 , min(1.0, percentage))
    }
    switch autoScrollDirection {
    case .Stay:
      return scrollRate(0)
    case .Top:
      return scrollRate(-speed)
    case .End:
      return scrollRate(speed)
    default:
      return scrollRate(0)
    }
  }
}