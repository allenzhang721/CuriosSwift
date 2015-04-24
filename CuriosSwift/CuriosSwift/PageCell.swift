//
//  PageCell.swift
//  CuriosSwift
//
//  Created by 星宇陈 on 4/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    var containerNode: ASDisplayNode?
    var containerNodeView: UIView?
    var nodeConstructionOperation: NSOperation?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let operation = nodeConstructionOperation {
            operation.cancel()
        }
        
        containerNode?.recursivelySetDisplaySuspended(true)
        containerNodeView?.removeFromSuperview()
        containerNodeView = nil
        containerNode = nil
    }
    
    func configCell(cellVM: PageModel, queue: NSOperationQueue) {
        
        if let oldOperation = nodeConstructionOperation {
            oldOperation.cancel()
        }
        
        let newOperation = configCellTaskBy(cellVM, queue: queue)
        nodeConstructionOperation = newOperation
        queue.addOperation(newOperation)
    }
}

// MARK - private
extension PageCell {
    
    private func configCellTaskBy(cellVM: PageModel, queue: NSOperationQueue) -> NSOperation {
        
        let operation = NSBlockOperation()
        operation.addExecutionBlock { [weak self, unowned operation] in
            
            if operation.cancelled {
                return
            }
            
            if let strongSelf = self {
                
                let aContaierNode = strongSelf.renderNodesBy(cellVM)
                
                if operation.cancelled {
                    return
                }
                dispatch_async(dispatch_get_main_queue(), { [weak operation] in
                    if let strongOperation = operation{
                        if strongOperation.cancelled{
                            return
                        }
                        
                        if strongSelf.nodeConstructionOperation != operation {
                            return
                        }
                        
                        if aContaierNode.displaySuspended {
                            return
                        }
                        
                        strongSelf.contentView.addSubview(aContaierNode.view)
                        aContaierNode.setNeedsDisplay()
                        strongSelf.containerNodeView = aContaierNode.view
                        strongSelf.containerNode = aContaierNode
                        println("end")
                    }
                    })
            }
        }
        return operation
    }
    
    private func renderNodesBy(cellVM: PageModel) -> ASDisplayNode {
        
        let aContainerNode = ASDisplayNode()
        aContainerNode.layerBacked = false
        aContainerNode.frame = self.bounds
        aContainerNode.userInteractionEnabled = true
        
        for itemVM in 0...20 {
            
            let node = ASEditableTextNode()
            node.layerBacked = false
            node.attributedText = NSAttributedString(string: "EMiaostein")
            node.frame.origin.x = 100
            node.frame.origin.y = 100
            node.bounds.size.width = 100
            node.bounds.size.height = 100
            //            let image = UIImage(named: "Cycling Tours.jpeg")
            //            node.image = image
            //            node.transform = CATransform3DMakeRotation(itemVM.rotation, 0, 0, 1)
            node.backgroundColor = UIColor.lightGrayColor()
            aContainerNode.addSubnode(node)
        }
        
        return aContainerNode
    }
}
