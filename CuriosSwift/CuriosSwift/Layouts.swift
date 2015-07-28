//
//  Layouts.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import UIKit

func POPTransition(progress: CGFloat, startValue: CGFloat, endValue: CGFloat) -> CGFloat {
    
    return CGFloat(startValue + (progress * (endValue - startValue)))
}




// MARK: - TemplateLayout
class TemplateLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        itemSize = LayoutSpec.layoutConstants.templateLayout.itemSize
        sectionInset = LayoutSpec.layoutConstants.templateLayout.sectionInsets
        scrollDirection = .Horizontal
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        itemSize = LayoutSpec.layoutConstants.templateLayout.itemSize
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset = LayoutSpec.layoutConstants.templateLayout.sectionInsets
        scrollDirection = .Horizontal
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
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
        static let normalLayoutInsetLeft: CGFloat = 22.0
        static let smallLayoutInsetTop: CGFloat = 20.0
        static let toolBarheight: CGFloat = 44.0
        static let screenSize:CGSize = UIScreen.mainScreen().bounds.size
        static let maxTransitionLayoutY = UIScreen.mainScreen().bounds.size.height * 0.618
        
        static var normalLayout: layoutAttributeStyle {
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
            let height = floorf(Float(screenSize.height * (1 - goldRatio) - smallLayoutInsetTop * 2.0))
            let width = floorf(height * Float(aspectRatio))
            let itemSize = CGSize(width: CGFloat(width), height: CGFloat(height))
            
            let top = smallLayoutInsetTop
            let bottom = screenSize.height - CGFloat(top) - CGFloat(height)
            let left = (screenSize.width - CGFloat(width)) / 2.0
            let right = left
            let sectionInset = UIEdgeInsetsMake(top, left, bottom, right)
            let scale = CGFloat(height) / normalLayout.itemSize.height
            
            return layoutAttributeStyle(itemSize: itemSize, sectionInsets: sectionInset, shrinkScale: scale)
        }
        
        static var templateLayout: layoutAttributeStyle {
            let height = floor((screenSize.height * goldRatio - toolBarheight) / 2.0)
            let width = screenSize.width / 3.0
            let itemSize = CGSize(width: width, height: height)
            let sectionInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            
            return layoutAttributeStyle(itemSize: itemSize, sectionInsets: sectionInsets, shrinkScale: 1.0)
        }
    }
}

