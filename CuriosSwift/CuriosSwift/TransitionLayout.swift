//
//  TransitionLayout.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/26/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

// MARK: - TransitionLayout
class TransitionLayout: UICollectionViewTransitionLayout {
  
  let smallHeight = LayoutSpec.layoutConstants.smallLayout.itemSize.height
  let normalWidth = LayoutSpec.layoutConstants.normalLayout.itemSize.width
  let normalHeight = LayoutSpec.layoutConstants.normalLayout.itemSize.height
  let minScale = floor(LayoutSpec.layoutConstants.smallLayout.shrinkScale * 1000)/1000.0
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    
    let att = super.layoutAttributesForElementsInRect(rect)
    if let attributes = att {
      for attribute in attributes as! [UICollectionViewLayoutAttributes] {
        if let cell = collectionView?.cellForItemAtIndexPath(attribute.indexPath) as? IcellTransition {
          
          let isSmall = currentLayout is smallLayout
          cell.transitionWithProgress(transitionProgress, isSmallSize: isSmall, minScale: minScale)
          
        }
      }
    }
    
    return att
  }
  
}