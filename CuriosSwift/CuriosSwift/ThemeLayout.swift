//
//  ThemeLayout.swift
//  
//
//  Created by Emiaostein on 7/19/15.
//
//

import UIKit

class ThemeLayout: UICollectionViewFlowLayout {
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    
    let activeDistance: CGFloat = 100.0
    let attributes = super.layoutAttributesForElementsInRect(rect) as! [UICollectionViewLayoutAttributes]
    let visualRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
    
    for attribute in attributes {
      if CGRectIntersectsRect(attribute.frame, rect) {
        let distance = visualRect.midX - attribute.center.x
        let normalDistance = distance / activeDistance
        if abs(distance) <= activeDistance {
          let scale = 1 + 0.1 * (1 - abs(normalDistance))
          attribute.transform3D = CATransform3DMakeScale(scale, scale, 1.0);
          attribute.zIndex = 1;
        }
      }
    }
    
    return attributes
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
