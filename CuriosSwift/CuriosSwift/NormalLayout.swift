//
//  NormalLayout.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/26/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation


// MARK: - normalLaout
class NormalLayout: UICollectionViewFlowLayout {
  
  override init() {
    super.init()
    itemSize = LayoutSpec.layoutConstants.normalLayout.itemSize
    sectionInset = LayoutSpec.layoutConstants.normalLayout.sectionInsets
    scrollDirection = .Horizontal
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    
    let att = super.layoutAttributesForElementsInRect(rect)
    if let attributes = att {
      for attribute in attributes as! [UICollectionViewLayoutAttributes] {
    if let cell = collectionView?.cellForItemAtIndexPath(attribute.indexPath) as? PageCollectionViewCell {
      cell.scale = 1.0
    }
      }
    }
    return att
  }
  
  override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    
    var offsetAdjustment: CGFloat = CGFloat(MAXFLOAT)
    let horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(collectionView!.bounds) / 2.0);
    let targetRect = CGRectMake(proposedContentOffset.x, 0.0, collectionView!.bounds.size.width, collectionView!.bounds.size.height);
    let array = super.layoutAttributesForElementsInRect(targetRect)
    for layoutattributes in array as! [UICollectionViewLayoutAttributes] {
      let itemHorizontalCenter = layoutattributes.center.x
      if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) {
        offsetAdjustment = itemHorizontalCenter - horizontalCenter
      }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y)
  }
}