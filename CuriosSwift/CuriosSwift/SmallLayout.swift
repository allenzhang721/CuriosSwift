//
//  SmallLayout.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/18/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol SmallLayoutDelegate: NSObjectProtocol {
    func layout(layout: UICollectionViewLayout, willMoveInAtIndexPath indexPath: NSIndexPath)
    func layout(layout: UICollectionViewLayout, willMoveOutFromIndexPath indexPath: NSIndexPath)
    func layout(layout: UICollectionViewLayout, willChangeFromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    func layoutDidMoveIn(layout: UICollectionViewLayout, didMoveInAtIndexPath indexPath: NSIndexPath)
    func layoutDidMoveOut(layout: UICollectionViewLayout)
    func layout(layout: UICollectionViewLayout, didFinished finished: Bool)
}

//MARK: - SmallLayout

class smallLayout: UICollectionViewFlowLayout {
    
    enum AutoScrollDirection {
        case Stay, Top, End
    }
    
    weak var delegate: SmallLayoutDelegate?
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
                if let cell = collectionView?.cellForItemAtIndexPath(attribute.indexPath) as? IcellTransition {
                    
                    cell.transitionWithProgress(0, isSmallSize: true, minScale: minScale)
                }
                if let selectedIndex = placeholderIndexPath?.item {
                    if selectedIndex == attribute.indexPath.item {
                        attribute.alpha = 0
                    } else {
                        attribute.alpha = 1
                    }
                }
            }
        }
        
        return att
    }
    
// MARK: - Public Method
// MARK: -

    // When Gesture Began
    func selectedItemBeganAtLocation(point: CGPoint) -> Bool {
        
        if let indexPath = collectionView?.indexPathForItemAtPoint(point) {
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
    
    func getSelectedItemSnapShot() -> UIView? {
        if let selectedIndexPath = placeholderIndexPath {
            let cell = collectionView?.cellForItemAtIndexPath(selectedIndexPath)
            return cell?.snapshotViewAfterScreenUpdates(false)
        } else {
            return nil
        }
    }
    
    // When Gesture changed
    func selectedItem(moveIn: Bool, AtLocation point: CGPoint) {
        if moveIn {
            if !pointMoveIn {
                pointMoveIn = true
                responseToPointMoveIn(point)
            }
            
            responseToPointMove(point)
            
        } else { // move out or out of here
            if pointMoveIn {
                pointMoveIn = false
                responseToPointWillMoveOut()
            }
        }
    }
    
    // When Gesture End
    func selectedItemMoveFinishAtLocation(point: CGPoint, fromeTemplate: Bool) {
        
        if let aPlaceholderIndexPath = placeholderIndexPath {
            if fromeTemplate {
                delegate?.layoutDidMoveIn(self, didMoveInAtIndexPath: aPlaceholderIndexPath)
            }
            
        } else {
            if !fromeTemplate {
                delegate?.layoutDidMoveOut(self)
            }
        }
        collectionView?.performBatchUpdates({ () -> Void in
            }, completion: nil)
        
        delegate?.layout(self, didFinished: true)
        
        collectionView?.scrollsToTop = true
        fakeCellCenter = CGPointZero
        placeholderIndexPath = nil
        reordering = false
        invalidateDisplayLink()
        invalidateLayout()
        
    }
}


// MARK: - Private Method
// MARK: - Items Modify
extension smallLayout {

    // Whten Gesture Move
    private func responseToPointMove(point: CGPoint) {
        if placeholderIndexPath == nil {
            return
        }
        fakeCellCenter = point
        autoScrollIfNeed(fakeCellCenter)
        changeItemIfNeed()
        
    }

    // move in
    private func responseToPointMoveIn(point: CGPoint) {
        if placeholderIndexPath == nil {
            placeholderIndexPath = getIndexPathByPointInBounds(point)
            
            if let aPlaceHolderIndexPath = placeholderIndexPath {
                placeholderIndexPath = getIndexPathByPointInBounds(point)
                fakeCellCenter = point
                if let aDelegate = delegate {
                    
                    // will move in delegate
                    aDelegate.layout(self, willMoveInAtIndexPath: aPlaceHolderIndexPath)
                    collectionView?.performBatchUpdates({ () -> Void in
                        
                        self.collectionView?.insertItemsAtIndexPaths([aPlaceHolderIndexPath])
                        
                        }, completion: { (completed) -> Void in
                    })
                }
            }
        }
    }
    
    
    // move out
    private func responseToPointWillMoveOut() {
        
        if let aPlacehoderIndexPath = placeholderIndexPath {
            self.delegate?.layout(self, willMoveOutFromIndexPath: aPlacehoderIndexPath)
            self.collectionView?.deleteItemsAtIndexPaths([aPlacehoderIndexPath])
            
            collectionView?.performBatchUpdates({ () -> Void in
                
                }, completion: { [unowned self] (completed) -> Void in
                    
                    if completed {
                    }
                    
                    self.fakeCellCenter = CGPointZero
                    self.placeholderIndexPath = nil
                    self.invalidateDisplayLink()
                    self.invalidateLayout()
                    self.collectionView?.performBatchUpdates({ () -> Void in
                        }, completion: nil)
                })
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
        
        self.delegate?.layout(self, willChangeFromIndexPath: fromIndexPath!, toIndexPath: toIndexPath!)
        collectionView?.performBatchUpdates({ [unowned self] () -> Void in
            self.placeholderIndexPath = toIndexPath
            self.collectionView?.moveItemAtIndexPath(fromIndexPath!, toIndexPath: toIndexPath!)
            }, completion: nil)
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
}

// MARK: - AutoScroll
extension smallLayout {
    
    private func autoScrollIfNeed(point: CGPoint) {
        let offset = collectionView?.contentOffset
        let triggerInsetTop: CGFloat = 40.0
        let triggerInsetEnd: CGFloat = 40.0
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
        
//        collectionView?.performBatchUpdates({ [unowned self] () -> Void in
            self.fakeCellCenter.x += scrollRate
            let contentOffset = CGPoint(x: self.collectionView!.contentOffset.x + scrollRate, y: self.collectionView!.contentOffset.y)
            self.collectionView?.contentOffset = contentOffset
//        changeItemIfNeed()
//            }, completion: nil)
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