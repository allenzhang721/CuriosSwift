//
//  Layouts.swift
//  CuriosSwift
//
//  Created by 星宇陈 on 4/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import UIKit

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


class smallLayout: UICollectionViewFlowLayout {
    
    
}

class LayoutSpec: NSObject {
    struct layoutAttributeStyle {
        let itemSize: CGSize
        let sectionInsets: UIEdgeInsets
        let shrinkScale: CGFloat
    }
    
    struct layoutConstants {
        static let goldRatio: CGFloat = 0.618
        static let aspectRatio: CGFloat = 320.0 / 504.0
        static let normalLayoutInsetLeft: CGFloat = 30.0
        static let smallLayoutInsetTop: CGFloat = 20.0
        static var screenSize:CGSize = UIScreen.mainScreen().bounds.size
        
        static var normalLayout: layoutAttributeStyle {
            println("normalLayout")
            let width = floorf(Float(screenSize.width - normalLayoutInsetLeft * 2.0))
            let height = CGFloat(width) / aspectRatio
            let itemSize = CGSizeMake(CGFloat(width), CGFloat(height))
            
            let top = floorf(Float(screenSize.height - itemSize.height) / 2.0)
            let bottom = top
            let left = normalLayoutInsetLeft
            let right = normalLayoutInsetLeft
            let sectionInset = UIEdgeInsetsMake(CGFloat(top), left, CGFloat(bottom), right)
            
            return layoutAttributeStyle(itemSize: itemSize, sectionInsets: sectionInset, shrinkScale: 1.0)
        }
        
        static var smallLayout: layoutAttributeStyle {
            println("smallLayout")
            let height = floorf(Float(screenSize.height * (1 - goldRatio) - smallLayoutInsetTop * 2.0))
            let width = floorf(height * Float(aspectRatio))
            let itemSize = CGSize(width: CGFloat(width), height: CGFloat(height))
            
            let top = smallLayoutInsetTop
            let bottom = screenSize.height - CGFloat(top) - CGFloat(height)
            let left = (screenSize.width - CGFloat(width)) / 2.0
            let right = left
            let sectionInset = UIEdgeInsetsMake(bottom, left, top, right)
            let scale = CGFloat(height) / normalLayout.itemSize.height
            
            return layoutAttributeStyle(itemSize: itemSize, sectionInsets: sectionInset, shrinkScale: scale)
        }
    }
}