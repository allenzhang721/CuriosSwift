//
//  PageCell.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/20/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    var containerNode: ASDisplayNode?
    var containerNodeView: UIView?
    var nodeConstructionOperation: NSOperation?
    var pageViewModel: PageViewModel!
//    var containerViewModels: [ContainerViewModel] = []
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
        pageViewModel = nil
        containerNodeView = nil
        containerNode = nil
    }
    
    func configCell(cellVM: PageViewModel, queue: NSOperationQueue) {
        
        if let oldOperation = nodeConstructionOperation {
            oldOperation.cancel()
        }
        
        pageViewModel = cellVM
        let newOperation = configCellTaskBy(pageViewModel, queue: queue)
        nodeConstructionOperation = newOperation
        queue.addOperation(newOperation)
    }
    
    func respondsToTapAction(sender: UITapGestureRecognizer) {
        
        
    }
}

// MARK: - multi Selection
extension PageCell {
    
    
}

// MARK: - private
extension PageCell {
    
    private func configCellTaskBy(cellVM: PageViewModel, queue: NSOperationQueue) -> NSOperation {
        
        let operation = NSBlockOperation()
        operation.addExecutionBlock { [weak self, unowned operation] in
            
            if operation.cancelled {
                return
            }
            
            if let strongSelf = self {
                
                let aContaierNode = strongSelf.renderNodesBy(cellVM)
                aContaierNode.backgroundColor = UIColor.orangeColor()
                aContaierNode.clipsToBounds = true
                
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
                    }
                    })
            }
        }
        return operation
    }
    
    private func renderNodesBy(cellVM: PageViewModel) -> ASDisplayNode {
        
        func getAspectRatio(cellVM: PageModel) -> CGFloat {
            let normalWidth = LayoutSpec.layoutConstants.normalLayout.itemSize.width
            let normalHeight = LayoutSpec.layoutConstants.normalLayout.itemSize.height
            return min(normalWidth / cellVM.width, normalHeight / cellVM.height)
        }
        
        func getNodeFrame(cellVM: PageViewModel) -> CGRect {
            let normalWidth = LayoutSpec.layoutConstants.normalLayout.itemSize.width
            let normalHeight = LayoutSpec.layoutConstants.normalLayout.itemSize.height
            let nodeWidth = cellVM.size.width * cellVM.aspectRatio
            let nodeHeight = cellVM.size.height * cellVM.aspectRatio
            let x = (normalWidth - nodeWidth) / 2.0
            let y = (normalHeight - nodeHeight) / 2.0
            return CGRectMake(x, y, nodeWidth, nodeHeight)
        }
        
//        let aspectRatio = PageViewModel.getAspectRatio(cellVM)
        let nodeFrome = getNodeFrame(cellVM)
        let aContainerNode = ASDisplayNode()
        aContainerNode.layerBacked = false
        aContainerNode.frame = nodeFrome
        
        aContainerNode.userInteractionEnabled = true
        
        for containerVM in pageViewModel.containers {
            let node = ContainerNode(aContainerViewModel: containerVM, aspectR: pageViewModel.aspectRatio)
//            let node = ContainerNode()
//            node.viewModel = containerVM
//            node.frame = CGRectMake(containerVM.x.value, containerVM.y.value, containerVM.width.value, containerVM.height.value)
            node.backgroundColor = UIColor.lightGrayColor()
            aContainerNode.addSubnode(node)
        }
        
        return aContainerNode
    }
    
//    private func getContainerViewModel(cellVM: PageModel) -> [ContainerViewModel] {
//        
//        var array: [ContainerViewModel] = []
//        let containerModels = cellVM.containers
//        
//        func getAspectRatio(cellVM: PageModel) -> CGFloat {
//            let normalWidth = LayoutSpec.layoutConstants.normalLayout.itemSize.width
//            let normalHeight = LayoutSpec.layoutConstants.normalLayout.itemSize.height
//            return min(normalWidth / cellVM.width, normalHeight / cellVM.height)
//        }
//        
//        for containerM in containerModels {
//            let containtVM = ContainerViewModel(model: containerM, aspectRatio:getAspectRatio(cellVM))
//            array.append(containtVM)
//        }
//        return array
//    }
}
