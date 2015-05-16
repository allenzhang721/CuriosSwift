//
//  PageCollectionViewCell.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

protocol IcellTransition {
    
    func transitionWithProgress(progress: CGFloat, isSmallSize: Bool, minScale: CGFloat)
}

class PageCollectionViewCell: UICollectionViewCell, IPage, IcellTransition {
    
    private var contentNode: ASDisplayNode?
    private var contentNodeView : UIView?
    private var nodeRenderOperation: NSOperation?
    private var pageModel: PageModel!
    private var aspectRatio: CGFloat = 0.0
    private var containers = [IContainer]()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let operation = nodeRenderOperation {
            operation.cancel()
        }
        
        contentNode?.recursivelySetDisplaySuspended(true)
        contentNodeView?.removeFromSuperview()
        containers.removeAll(keepCapacity: true)
        pageModel = nil
        contentNodeView = nil
        contentNode = nil
    }
    
    func configCell(aPageModel: PageModel, queue: NSOperationQueue) {
        
        if let oldOperation = nodeRenderOperation {
            oldOperation.cancel()
        }
        
        pageModel = aPageModel
        aspectRatio = getAspectRatioWithPageModel(aPageModel)
        let newOperation = configPageWithPageModel(aPageModel, queue: queue)
        nodeRenderOperation = newOperation
        queue.addOperation(newOperation)
    }
    
    func transitionWithProgress(progress: CGFloat, isSmallSize: Bool, minScale: CGFloat) {
        
        let scale = POPTransition(progress, isSmallSize ? minScale : 1.0, isSmallSize ? 1.0 : minScale)
                                contentNode!.transform = CATransform3DMakeScale(scale, scale, 1)
                                contentNodeView!.center = contentView.center;
    }
}

// MARK: - Private Method
extension PageCollectionViewCell {
    
    private func configPageWithPageModel(aPageModel: PageModel, queue: NSOperationQueue) -> NSOperation {
        let operation = NSBlockOperation()
        operation.addExecutionBlock { [weak self, unowned operation] in
            
            if operation.cancelled {
                return
            }
            
            if let strongSelf = self {
                
                let content: (ASDisplayNode, [IContainer]) = strongSelf.getContainerNodesWithPageModel(aPageModel)
                content.0.backgroundColor = UIColor.orangeColor()
                content.0.clipsToBounds = true
                
                if operation.cancelled {
                    return
                }
                dispatch_async(dispatch_get_main_queue(), { [weak operation] in
                    if let strongOperation = operation{
                        if strongOperation.cancelled{
                            return
                        }
                        
                        if strongSelf.nodeRenderOperation != operation {
                            return
                        }
                        
                        if content.0.displaySuspended {
                            return
                        }
                        
                        strongSelf.contentView.addSubview(content.0.view)
                        content.0.setNeedsDisplay()
                        strongSelf.contentNodeView = content.0.view
                        strongSelf.containers = content.1
                        strongSelf.contentNode = content.0
                    }
                    })
            }
        }
        
        
        
        return operation
    }
    
    private func getContainerNodesWithPageModel(aPageModel: PageModel) -> (ASDisplayNode, [IContainer]) {
        let aContentNode = ASDisplayNode()
        var aContainers = [IContainer]()
        let contentNodeFrame = getContentNodeFrame(aPageModel)
        aContentNode.frame = contentNodeFrame
        aContentNode.layerBacked = false
        
        for containerModel in aPageModel.containers {
            let aContainerNode = getContainerWithModel(containerModel) as ContainerNode
            aContentNode.addSubnode(aContainerNode)
            aContainers.append(aContainerNode)
        }
        
        return (aContentNode, aContainers)
    }
    
   
    
    
    private func getContainerWithModel(aContainerModel: ContainerModel) -> ContainerNode {
        
        let info = getAContainerInfo(aContainerModel)
        
        let aContainerNode = ContainerNode(postion: info.0, size: info.1, rotation: info.2, aspectRatio: aspectRatio, aContainerModel: aContainerModel)
        aContainerNode.backgroundColor = UIColor.lightGrayColor()
        
        return aContainerNode
    }
    
// MARK: - Calculate
    private func getContentNodeFrame(aPageModel: PageModel) -> CGRect {
        
        let normalWidth = LayoutSpec.layoutConstants.normalLayout.itemSize.width
        let normalHeight = LayoutSpec.layoutConstants.normalLayout.itemSize.height
        let nodeWidth = aPageModel.width * aspectRatio
        let nodeHeight = aPageModel.height * aspectRatio
        let x = (normalWidth - nodeWidth) / 2.0
        let y = (normalHeight - nodeHeight) / 2.0
        
        let frame = CGRectMake(x, y, nodeWidth, nodeHeight)
        
        return frame
    }
    
    private func getAspectRatioWithPageModel(aPageModel: PageModel) -> CGFloat {
        
        let normalWidth = LayoutSpec.layoutConstants.normalLayout.itemSize.width
        let normalHeight = LayoutSpec.layoutConstants.normalLayout.itemSize.height
        return min(normalWidth / aPageModel.width, normalHeight / aPageModel.height)
    }
    
    private func getAContainerInfo(aContainerModel: ContainerModel) -> (CGPoint, CGSize, CGFloat) {
        
        let width = aContainerModel.width * aspectRatio
        let height = aContainerModel.height * aspectRatio
        let x = (aContainerModel.x + aContainerModel.width / 2.0 ) * aspectRatio
        let y = (aContainerModel.y + aContainerModel.height / 2.0 ) * aspectRatio
        
        let position = CGPoint(x: x, y: y)
        let size = CGSize(width: width, height: height)
        let rotation: CGFloat = aContainerModel.alpha
        
        return (position, size, rotation)
    }
}
