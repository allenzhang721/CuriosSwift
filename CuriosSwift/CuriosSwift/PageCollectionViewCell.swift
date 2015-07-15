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

protocol PageCollectionViewCellDelegate: NSObjectProtocol {
  
  func pageCollectionViewCellGetUserIDandPublishID(cell: PageCollectionViewCell) -> (String, String)
}

class PageCollectionViewCell: UICollectionViewCell, PageModelDelegate, IPage, IcellTransition {
  
  internal weak var delegate: IPageProtocol?      //Mr.chen, 05/16/2015, 16:01, Note: will become retain cycle
  weak var pageCellDelegate: PageCollectionViewCellDelegate?
  private var contentNode: ASDisplayNode?
  private var contentNodeView : UIView?
  private var nodeRenderOperation: NSOperation?
  private var pageModel: PageModel!
  private var aspectRatio: CGFloat = 0.0
  
  override func prepareForReuse() {
    super.prepareForReuse()
    if let operation = nodeRenderOperation {
      operation.cancel()
    }
    
    contentNode?.recursivelySetDisplaySuspended(true)
    contentNodeView?.removeFromSuperview()
    pageModel = nil
    contentNodeView = nil
    contentNode = nil
  }
  
  func configCell(aPageModel: PageModel, queue: NSOperationQueue) {
    
    if let oldOperation = nodeRenderOperation {
      oldOperation.cancel()
    }
    
    pageModel = aPageModel
    pageModel.modelDelegate = self
    
    aspectRatio = getAspectRatioWithPageModel(aPageModel)
    let newOperation = configPageWithPageModel(aPageModel, queue: queue)
    nodeRenderOperation = newOperation
    queue.addOperation(newOperation)
  }
  
  func transitionWithProgress(progress: CGFloat, isSmallSize: Bool, minScale: CGFloat) {
    
    let scale = POPTransition(progress, isSmallSize ? minScale : 1.0, isSmallSize ? 1.0 : minScale)
    if let aContentNode = contentNode {
      aContentNode.transform = CATransform3DMakeScale(scale, scale, 1)
      contentNodeView!.center = contentView.center
    }
    
  }
}

// MARK: - PageModel Delegate
extension PageCollectionViewCell {
  
  func targetPageModel(model: PageModel, DidAddContainer container: ContainerModel) {
    
    addContainerByModel(container)
  }
  
  func targetpageModel(model: PageModel, DidRemoveContainer container: ContainerModel) {
    
    removeContainerByModel(container)
  }
}





















// MARK: - PageView Interface
extension PageCollectionViewCell {
  
  func addContainerByModel(model: ContainerModel) {
    
    if let aContentNode = contentNode {
      
      let containerNode = getContainerWithModel(model)
      aContentNode.addSubnode(containerNode)
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        aContentNode.setNeedsDisplay()
      })
    }
  }
  
  func removeContainerByModel(model: ContainerModel) {
    
    if let aContentNode = contentNode,
       let containerNodes = aContentNode.subnodes as? [ContainerNode] {
        for containerNode in containerNodes {
          if containerNode.containAcontainer(model) {
            containerNode.removeFromSupernode()
            break
          }
        }
    }
  }
  
  // begain selected
  func begainResponseToTap(onScreenPoint: CGPoint, tapCount: Int) {
    
    switch tapCount {
    case 1:
      singleTap(onScreenPoint)
      
    case 2:
      doubleTap(onScreenPoint)
      
    default:
      return
    }
  }
  
  // single selected
  func singleTap(onScreenPoint: CGPoint) {

    if contentNode?.subnodes.count <= 0 {
      return
    }
    
    let aContentNode = contentNode!
    let reverseSubNodes = aContentNode.subnodes.reverse() as! [ContainerNode]
    
    func pointInContainerNode(node: ContainerNode?) {
      // selected
      if let containerModel = node?.containerModel {
        if containerModel.selected {
          
        } else {
          
          for aContainerModel in pageModel.containers {
            
            if aContainerModel.selected {
              aContainerModel.setSelectedState(false)
              delegate?.pageDidDeSelected(pageModel, deselectedContainer: aContainerModel)
            }
          }
          containerModel.setSelectedState(true)
          delegate?.pageDidSelected(pageModel, selectedContainer: containerModel, onView: aContentNode.view, onViewCenter: node!.view.center, size: node!.view.bounds.size, angle: containerModel.rotation)
        }
        
      // End Edit
      } else {
        var needEndEdit = false
        for containerNode in reverseSubNodes {
          
          if containerNode.containerModel.selected {
            let aContainerModel = containerNode.containerModel
            needEndEdit = true
            aContainerModel.setSelectedState(false)
            
            // create text snapshot when deseleted
            if let aComponent = aContainerModel.component as? TextContentModel where aComponent.needUpload {
              let userIDandPublishID: (String, String) = pageCellDelegate!.pageCollectionViewCellGetUserIDandPublishID(self)
              // should get text/ image snapshot
              let abounds = containerNode.bounds
              UIGraphicsBeginImageContextWithOptions(abounds.size, false, 1 / aspectRatio)
              containerNode.view.drawViewHierarchyInRect(abounds, afterScreenUpdates: false)
              let image = UIGraphicsGetImageFromCurrentImageContext()!
              UIGraphicsEndImageContext()
              
              aComponent.cacheSnapshotImage(image, userID: userIDandPublishID.0, PublishID: userIDandPublishID.1)
            }
            
            delegate?.pageDidDeSelected(pageModel, deselectedContainer: aContainerModel)
          }
        }
        if needEndEdit {
          delegate?.pageDidEndEdit(pageModel)
        }
      }
    }
    
    var find = false
    var findNode: ContainerNode? = nil
    
    for subNode in reverseSubNodes {
      let point = convertPoint(onScreenPoint, toView: subNode.view)
      if CGRectContainsPoint(subNode.view.bounds, point) {
        println("on container")
        findNode = subNode
        break
      }
    }
    
    pointInContainerNode(findNode)
  }
  
  // double selected
  func doubleTap(onScreenPoint: CGPoint) {
    
    if contentNode?.subnodes.count <= 0 {
      return
    }
    
    let aContentNode = contentNode!
    let reverseSubNodes = aContentNode.subnodes.reverse() as! [ContainerNode]
    
    func pointInContainerNode(node: ContainerNode) {
      let containerModel = node.containerModel
      delegate?.pageDidDoubleSelected(pageModel, doubleSelectedContainer: containerModel)
    }
    
    for subNode in reverseSubNodes {
      let point = convertPoint(onScreenPoint, toView: subNode.view)
      if CGRectContainsPoint(subNode.view.bounds, point) {
        pointInContainerNode(subNode)
        break
      }
    }
  }
  //
  
  // end selected
  
}





























// MARK: - IPage
extension PageCollectionViewCell {
  
  func setDelegate(aDelegate: IPageProtocol) {
    delegate = aDelegate
  }
  func cancelDelegate() {
    delegate = nil
  }

  func saveInfo() {
    //
    //        for container in containers {
    //
    //            if let component = container.component as? ITextComponent where component.getNeedUpload() {
    //
    ////                let image = container.getSnapshotImageAfterScreenUpdate(false)
    ////
    //                let attributeString = component.getAttributeText()
    //                let size = container.containerSize
    ////
    //                let textView = UITextView(frame: CGRectMake(0, 0, size.width, size.height))
    //                textView.attributedText = attributeString
    //                textView.textColor = UIColor.whiteColor()
    //                textView.backgroundColor = UIColor.blackColor()
    //
    //                UIGraphicsBeginImageContext(size)
    //                textView.drawViewHierarchyInRect(textView.bounds, afterScreenUpdates: true)
    //                let image = UIGraphicsGetImageFromCurrentImageContext()!
    //                UIGraphicsEndImageContext()
    //
    //                let imageData = UIImageJPEGRepresentation(image, 0.01)
    //                let pagePath = pageModel.fileGetSuperPath(pageModel)
    //                let relativePath = component.getImageRelativePath()
    ////                let imagePath = pagePath.stringByAppendingPathComponent(relativePath)
    //              let imagePath = temporaryDirectory("\(component.getImageRelativePath()).jpg").path!
    //
    //                println("textImagePath: \(imagePath)")
    //                if NSFileManager.defaultManager().removeItemAtPath(imagePath, error: nil) {
    //
    //                    println("remove file")
    //                }
    //
    //                if imageData.writeToFile(imagePath, atomically: true) {
    //
    //                   println("iamge write scuccessful")
    //
    //
    //                }
    //            }
    //        }
    //
    //        pageModel.saveInfo()
  }
  
  
  func exchangeContainerFromIndex(fromIndex: Int, toIndex: Int) {
    exchange(&pageModel.containers, fromIndex, toIndex)
    saveInfo()
  }
  
}

// MARK: - Private Method
extension PageCollectionViewCell {
  
  
  private func respondToLongPressLocation(location: CGPoint, onTargetView targetView: UIView) -> Bool {
    
    return false
  }
  
  private func configPageWithPageModel(aPageModel: PageModel, queue: NSOperationQueue) -> NSOperation {
    let operation = NSBlockOperation()
    operation.addExecutionBlock { [weak self, unowned operation] in
      
      if operation.cancelled {
        return
      }
      
      if let strongSelf = self {
        
        let aContentNode: ASDisplayNode = strongSelf.getContainerNodesWithPageModel(aPageModel)
        aContentNode.backgroundColor = UIColor.blackColor()
        aContentNode.clipsToBounds = true
        
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
            
            if aContentNode.displaySuspended {
              return
            }
            
            strongSelf.contentView.addSubview(aContentNode.view)
            aContentNode.setNeedsDisplay()
            strongSelf.contentNodeView = aContentNode.view
            strongSelf.contentNode = aContentNode
          }
          })
      }
    }
    
    return operation
  }
  
  private func getContainerNodesWithPageModel(aPageModel: PageModel) -> ASDisplayNode {
    let aContentNode = ASDisplayNode()
    let contentNodeFrame = getContentNodeFrame(aPageModel)
    aContentNode.frame = contentNodeFrame
    aContentNode.layerBacked = false
    
    for containerModel in aPageModel.containers {
      let aContainerNode = getContainerWithModel(containerModel) as ContainerNode
      aContentNode.addSubnode(aContainerNode)
//      aContainerNode.page = self
    }
    
    return aContentNode
  }

  
  private func getContainerWithModel(aContainerModel: ContainerModel) -> ContainerNode {
    
    let info = getAContainerInfo(aContainerModel)
    
    let aContainerNode = ContainerNode(postion: info.0, size: info.1, rotation: info.2, aspectRatio: aspectRatio, aContainerModel: aContainerModel)
    
    let size = aContainerNode.measure(CGSize(width: CGFloat.max, height: CGFloat.max))
    aContainerNode.bounds.size = size
    aContainerModel.setOnScreenSize(size)
//    aContainerNode.bindingContainerModel()
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
  
  // scale : cellSize / pageModelSize
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
    let rotation: CGFloat = aContainerModel.rotation
    
    return (position, size, rotation)
  }
}
