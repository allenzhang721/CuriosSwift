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
        
        for itemVM in cellVM.items {
            
            let node = ASEditableTextNode()
            node.layerBacked = false
            node.attributedText = NSAttributedString(string: "EMiaostein")
            node.frame.origin.x = CGFloat(itemVM.x - itemVM.width)
            node.frame.origin.y = CGFloat(itemVM.y - itemVM.height)
            node.bounds.size.width = CGFloat(itemVM.width)
            node.bounds.size.height = CGFloat(itemVM.height)
            //            let image = UIImage(named: "Cycling Tours.jpeg")
            //            node.image = image
            //            node.transform = CATransform3DMakeRotation(itemVM.rotation, 0, 0, 1)
            node.backgroundColor = UIColor(red: CGFloat(Double(itemVM.width % 255) / 255.0), green: CGFloat(Double(itemVM.width) / 255.0), blue: CGFloat(Double(itemVM.width) / 255.0), alpha: 1)
            aContainerNode.addSubnode(node)
        }
        
        return aContainerNode
    }
}
