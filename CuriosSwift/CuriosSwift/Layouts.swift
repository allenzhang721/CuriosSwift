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

protocol SmallLayoutDelegate {
    func didMoveInAtIndexPath(indexPath: NSIndexPath)
    func willMoveOutAtIndexPath(indexPath: NSIndexPath)
    func didMoveOutAtIndexPath(indexPath: NSIndexPath)
    func didMoveEndAtIndexPath(indexPath: NSIndexPath)
    func didChangeFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
}

//MARK: - SmallLayout

class smallLayout: UICollectionViewFlowLayout {
    
    enum AutoScrollDirection {
        case Stay, Top, End
    }
    
    var delegate: SmallLayoutDelegate?
    var placeholderIndexPath: NSIndexPath?
   private var reordering = false
   private var pointMoveIn = false
   private var fakeCellCenter = CGPointZero
   private var autoScrollDirection: AutoScrollDirection = .Stay
   private var displayLink: CADisplayLink?
    
    let minScale = floor(LayoutSpec.layoutConstants.smallLayout.shrinkScale * 1000)/1000.0
    
    override init() {
        super.init()
        setuoProperties()
    }
    
    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
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
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
        let att = super.layoutAttributesForElementsInRect(rect)
        if let attributes = att {
            for attribute in attributes as! [UICollectionViewLayoutAttributes] {
                if let cell = collectionView?.cellForItemAtIndexPath(attribute.indexPath) as? PageCell {
                    if let containerNode = cell.containerNode {
                        containerNode.transform = CATransform3DMakeScale(minScale, minScale, 1)
                        containerNode.view.center = cell.contentView.center
//                        containerNode.transform = CATransform3DTranslate(containerNode.transform, CGFloat(100.0), CGFloat(100.0), 0)
                    }
                }
            }
        }
        
        return att
    }
    
    func responsetoPointMoveEnd() {
        
        if let aPlaceholderIndexPath = placeholderIndexPath {
            self.delegate?.didMoveOutAtIndexPath(aPlaceholderIndexPath)
        }
        
        collectionView?.scrollsToTop = true
        fakeCellCenter = CGPointZero
        placeholderIndexPath = nil
        reordering = false
        invalidateDisplayLink()
        invalidateLayout()
        collectionView?.performBatchUpdates({ () -> Void in
        }, completion: nil)
    }
    
    func shouldRespondsToGestureLocation(location: CGPoint) -> Bool {
        if let indexPath = collectionView?.indexPathForItemAtPoint(location) {
            placeholderIndexPath = indexPath
            reordering = true
            collectionView?.performBatchUpdates({ () -> Void in
            }, completion: { (completion) -> Void in
            })
            return true
        } else {
            reordering = false
            return false
        }
    }
    
    func getResponseViewSnapShot() -> UIView? {
        
        if let selectedIndexPath = placeholderIndexPath {
            let cell = collectionView?.cellForItemAtIndexPath(selectedIndexPath)
            return cell?.snapshotViewAfterScreenUpdates(false)
        } else {
            return nil
        }
    }
    
    func responseToPointMoveInIfNeed(moveIn: Bool, AtPoint point: CGPoint) {
        
        if moveIn {
            if !pointMoveIn {
                pointMoveIn = true
                if placeholderIndexPath == nil {
                    placeholderIndexPath = getIndexPathByPointInBounds(point)
                    fakeCellCenter = point
                    if let aDelegate = delegate {
                        aDelegate.didMoveInAtIndexPath(placeholderIndexPath!)
                        collectionView?.performBatchUpdates({ () -> Void in
                            }, completion: { (completed) -> Void in
                        })
                    }
                }
            }
            
            responseToPointMove(point)
            
        } else { // move out or out of here
            if pointMoveIn {
                pointMoveIn = false
                responseToPointMoveOut()
            }
        }
    }
    
    private func getIndexPathByPointInBounds(point: CGPoint) -> NSIndexPath {
        let contentSize = collectionView?.contentSize
        let leftEdge = sectionInset.left
        let rigthEdge = contentSize!.width - sectionInset.right
        let visualCells = collectionView?.visibleCells()
        let x = point.x
        var placeHolderIndexpath = NSIndexPath(forItem: 0, inSection: 0)
        
        if visualCells?.count > 0 {
            
            switch x {
            case let x where x < leftEdge:
                    placeholderIndexPath = NSIndexPath(forItem: 0, inSection: 0)
            case let x where x > rigthEdge:
                let lastCell = visualCells?.last as! UICollectionViewCell
                let lastIndexPath = collectionView?.indexPathForCell(lastCell)
                placeholderIndexPath = NSIndexPath(forItem: lastIndexPath!.item + 1, inSection: 0)
                
            default:
                var find = false
                for cell in visualCells as! [UICollectionViewCell] {
                    if cell.center.x > x {
                        find = true
                        placeholderIndexPath = collectionView?.indexPathForCell(cell)
                        break
                    }
                }
                
                if find == false {
                    let lastCell = visualCells?.last as! UICollectionViewCell
                    let lastIndexPath = collectionView?.indexPathForCell(lastCell)
                    placeholderIndexPath = NSIndexPath(forItem: lastIndexPath!.item + 1, inSection: 0)
                }
            }
        } else {
            placeholderIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        }
        
        return placeholderIndexPath!
    }
    
    private func responseToPointMove(point: CGPoint) {
        if placeholderIndexPath == nil {
            return
        }
        fakeCellCenter = point
        autoScrollIfNeed(fakeCellCenter)
        changeItemIfNeed()
    }
    
    private func responseToPointMoveOut() {
        
        if let aPlacehoderIndexPath = placeholderIndexPath {
            self.delegate?.willMoveOutAtIndexPath(aPlacehoderIndexPath)
            collectionView?.performBatchUpdates({ () -> Void in
            }, completion: { [unowned self] (completed) -> Void in
                
                if completed {
                    self.delegate?.didMoveOutAtIndexPath(aPlacehoderIndexPath)
                }
                self.collectionView?.scrollsToTop = true
                self.fakeCellCenter = CGPointZero
                self.placeholderIndexPath = nil
                self.invalidateDisplayLink()
                self.invalidateLayout()
                self.collectionView?.performBatchUpdates({ () -> Void in
                }, completion: nil)
            })
        }
    }
    
    private func autoScrollIfNeed(point: CGPoint) {
        let offset = collectionView?.contentOffset
        let triggerInsetTop: CGFloat = 100.0
        let triggerInsetEnd: CGFloat = 100.0
        let contentLength = CGRectGetWidth(collectionView!.bounds)
        switch point.x {
        case let x where x <= (offset!.x + triggerInsetTop):
            autoScrollDirection = .Top
            setupDisplayLink()
        case let x where x >= offset!.x + contentLength - triggerInsetEnd:
            autoScrollDirection = .End
            setupDisplayLink()
        default:
            invalidateDisplayLink()
        }
    }
    
    private func changeItemIfNeed() {
        var fromIndexPath: NSIndexPath?
        var toIndexPath: NSIndexPath?
        if let aPlaceholderIndexPath = placeholderIndexPath {
            fromIndexPath = aPlaceholderIndexPath
            toIndexPath = collectionView?.indexPathForItemAtPoint(fakeCellCenter)
        }
        if fromIndexPath == nil || toIndexPath == nil {
            return
        }
        if fromIndexPath == toIndexPath {
            return
        }
        
        //TODO: delegate can move item
        //...
        
        self.delegate?.didChangeFromIndexPath(fromIndexPath!, toIndexPath: toIndexPath!)
        collectionView?.performBatchUpdates({ [unowned self] () -> Void in
            self.placeholderIndexPath = toIndexPath
            self.collectionView?.moveItemAtIndexPath(fromIndexPath!, toIndexPath: toIndexPath!)
        }, completion: nil)
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
        if placeholderIndexPath == nil {
            return
        }
        let percentage: CGFloat = 0.5
        var scrollRate = calcscrollRateIfNeedWithSpeed(10.0, percentage: percentage)
        let offsetTop = collectionView!.contentOffset.x
        let insetTop: CGFloat = 100.0
        let insetEnd: CGFloat = 100.0
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
        
        collectionView?.performBatchUpdates({ [unowned self] () -> Void in
            self.fakeCellCenter.x += scrollRate
            let contentOffset = CGPoint(x: self.collectionView!.contentOffset.x + scrollRate, y: self.collectionView!.contentOffset.y)
            self.collectionView?.contentOffset = contentOffset
        }, completion: nil)
    }
    
    private func calcscrollRateIfNeedWithSpeed(speed: CGFloat, percentage: CGFloat) -> CGFloat {
        if placeholderIndexPath == nil {
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
                if let cell = collectionView?.cellForItemAtIndexPath(attribute.indexPath) as? PageCell {
                    if let containerNode = cell.containerNode {
                        let isNor = currentLayout is NormalLayout
                        let scale = POPTransition(transitionProgress, isNor ? 1.0 : minScale, isNor ? minScale : 1.0)
                        containerNode.transform = CATransform3DMakeScale(scale, scale, 1)
                        containerNode.view.center = cell.contentView.center;
                        
                    }

                }
                
            }
        }
     
        return att
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
        static let normalLayoutInsetLeft: CGFloat = 30.0
        static let smallLayoutInsetTop: CGFloat = 20.0
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
    }
}

