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

class PageCollectionViewCell: UICollectionViewCell, PageModelDelegate, IPage, IcellTransition {
  
  internal weak var delegate: IPageProtocol?      //Mr.chen, 05/16/2015, 16:01, Note: will become retain cycle
  private var contentNode: ASDisplayNode?
  private var contentNodeView : UIView?
  private var nodeRenderOperation: NSOperation?
  private var pageModel: PageModel!
  private var aspectRatio: CGFloat = 0.0

  private var containers = [IContainer]()
  private var selectedContainers = [IContainer]()
  
  private var contentNodeCenter: CGPoint {
    get {
      return contentNodeView?.center ?? CGPointZero
    }
  }
  
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
//      let size = containerNode.measure(CGSize(width: CGFloat.max, height: CGFloat.max))
//      containerNode.bounds.size = size
//      model.setOnScreenSize(size)
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
              aContainerModel.selected = false
              delegate?.pageDidDeSelected(pageModel, deselectedContainer: aContainerModel)
            }
          }
          containerModel.selected = true
          delegate?.pageDidSelected(pageModel, selectedContainer: containerModel, onView: aContentNode.view, onViewCenter: node!.view.center, size: node!.view.bounds.size, angle: containerModel.rotation)
        }
        
      // End Edit
      } else {
        var needEndEdit = false
        for aContainerModel in pageModel.containers {
          
          if aContainerModel.selected {
            needEndEdit = true
            aContainerModel.selected = false
            delegate?.pageDidDeSelected(pageModel, deselectedContainer: aContainerModel)
          }
        }
        if needEndEdit {
          delegate?.pageDidEndEdit(pageModel)
        }
      }
    }
    
    var find = false
    for subNode in reverseSubNodes {
      let point = convertPoint(onScreenPoint, toView: subNode.view)
      if CGRectContainsPoint(subNode.view.bounds, point) {
        
        pointInContainerNode(subNode)
        find = true
        break
      }
    }
    
    if !find {
      pointInContainerNode(nil)
    }
  }
  
  // double selected
  func doubleTap(onScreenPoint: CGPoint) {
  
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
  
  func addContainer(aContainerModel: ContainerModel, finishCompletedBlock:((UIImage) -> ())? = nil) {
    
    pageModel.addContainer(aContainerModel)
    
    if let aContentNode = contentNode {
      let realWidth = aContainerModel.width
      let realHeight = aContainerModel.height
      let centerX = contentNodeCenter.x
      let centerY = contentNodeCenter.y
      let x = centerX - realWidth / 2.0
      let y = centerY - realHeight / 2.0
      aContainerModel.x = centerX
      aContainerModel.y = centerY
      
      let containerNode = getContainerWithModel(aContainerModel)
      containerNode.page = self
      containerNode.component.setNeedUpload(true)
      containers.append(containerNode)
      contentNode?.addSubnode(containerNode)
      
      
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        aContentNode.setNeedsDisplay()
        let image = containerNode.view.snapshotImageAfterScreenUpdate(true)
        finishCompletedBlock?(image)
      })
      //            pageModel.saveInfo()
    }
  }
  
  func setNeedUpload(needUpload: Bool) {
    
    pageModel.needUpload = needUpload
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
  
  func uploadInfo(userID: String, publishID: String) {
    pageModel.uploadInfo(userID, publishID: publishID)
  }
  
  func removeContainer(aContainerModel: ContainerModel) {
    
    pageModel.removeContainer(aContainerModel)
    if contentNode != nil {
      
      for (index, subNode) in enumerate(contentNode?.subnodes as! [ContainerNode]) {
        
        if subNode.containAcontainer(aContainerModel) {
          
          for (index, theSuNode) in enumerate(containers) {
            
            if theSuNode.isEqual(subNode) {
              containers.removeAtIndex(index)
              break
            }
          }
          
          for (index, theSuNode) in enumerate(selectedContainers) {
            
            if theSuNode.isEqual(subNode) {
              selectedContainers.removeAtIndex(index)
              break
            }
          }
          
          subNode.removeFromSupernode()
          break
        }
      }
    }
    saveInfo()
  }
  
  func exchangeContainerFromIndex(fromIndex: Int, toIndex: Int) {
    exchange(&pageModel.containers, fromIndex, toIndex)
    saveInfo()
  }
  
  func respondToLocation(location: CGPoint, onTargetView targetView: UIView, sender: UIGestureRecognizer?) -> Bool {
    
    if let gesture = sender {
      switch gesture {
      case let gesture as UITapGestureRecognizer where gesture.numberOfTapsRequired == 1 :
        return respondToSingleTapLocation(location, onTargetView: targetView)
      case let gesture as UITapGestureRecognizer where gesture.numberOfTapsRequired == 2 :
        return respondToDoubleTapLocation(location, onTargetView: targetView)
      case is UILongPressGestureRecognizer :
        return respondToLongPressLocation(location, onTargetView: targetView)
      default:
        return false
      }
    } else {
      let reverseContainers = containers.reverse()
      var find = false
      for container in reverseContainers {
        if container.responderToLocation(location, onTargetView: targetView) {
          find = true
          break
        }
      }
      
      if !find {
        for container in reverseContainers {
          if container.isFirstResponder() {
            container.resignFirstResponder()
            break
          }
        }
      }
      
      return find
    }
  }
}

// MARK: - Private Method
extension PageCollectionViewCell {
  
  private func respondToSingleTapLocation(location: CGPoint, onTargetView targetView: UIView) -> Bool {
    
    if let aDelegate = delegate {
      
      let reverseContainers = containers.reverse()
      var find = false
      // multi selection
      if aDelegate.shouldMultiSelection() {
        
        for container in reverseContainers {
          if container.responderToLocation(location, onTargetView: targetView) {
            find = true
            var selected = false
            for con in selectedContainers {
              if con.isEqual(container) {
                selected = true
                break
              }
            }
            // selected or deselected
            selected ? selectedContainer(container, location: location, onTargetView: targetView) : deselectedContainer(container)
          }
          break
        }
        // single selection
      } else {
        
        for container in reverseContainers {
          if container.responderToLocation(location, onTargetView: targetView) {
            deselectedAllContainers()
            selectedContainer(container, location: location, onTargetView: targetView)
            find = true
            break
          }
        }
        
        if !find {
          deselectedAllContainers()
          aDelegate.didEndEdit(self)
        }
      }
      
      return find
      
    } else {
      return false
    }
  }
  
  private func respondToDoubleTapLocation(location: CGPoint, onTargetView targetView: UIView) -> Bool {
    
    if let aDelegate = delegate {
      
      let reverseContainers = containers.reverse()
      var find = false
      
      for container in reverseContainers {
        if container.responderToLocation(location, onTargetView: targetView) {
          //                    deselectedAllContainers()
          aDelegate.pageDidDoubleSelected(self, doubleSelectedContainer: container)
          find = true
          break
        }
      }
      
      return find
      
      //            if find {
      //                deselectedAllContainers()
      //                aDelegate.didEndEdit(self)
      //            }
      
    } else {
      
      return false
    }
  }
  
  private func respondToLongPressLocation(location: CGPoint, onTargetView targetView: UIView) -> Bool {
    
    return false
  }
  
  private func selectedContainer(container: IContainer, location: CGPoint, onTargetView targetView: UIView) {
    
    if let aDelegate = delegate {
      let position = contentNodeView?.convertPoint(container.containerPostion, toView: targetView)
      let size = container.containerSize
      let rotation = container.containerRotation
      let aRatio = size.height / size.width
      aDelegate.pageDidSelected(self, selectedContainer: container, position: position!, size: size, rotation: rotation, ratio: aRatio, inTargetView: targetView)
    }
    selectedContainers.append(container)
  }
  
  private func deselectedContainer(container: IContainer) {
    
    if selectedContainers.count > 0 {
      
      if let aDelegate = delegate {
        aDelegate.pageDidDeSelected(self, deSelectedContainers: [container])
        if container.isFirstResponder() {
          container.resignFirstResponder()
        }
      }
      var index = 0
      for con in selectedContainers {
        if con.isEqual(container) {
          break
        }
        index++
      }
      selectedContainers.removeAtIndex(index)
    }
  }
  
  private func deselectedAllContainers() {
    
    if selectedContainers.count > 0 {
      
      if let aDelegate = delegate {
        aDelegate.pageDidDeSelected(self, deSelectedContainers: selectedContainers)
        for container in selectedContainers {
          if container.isFirstResponder() {
            container.resignFirstResponder()
          }
        }
      }
      selectedContainers.removeAll(keepCapacity: true)
    }
  }
  
  private func configPageWithPageModel(aPageModel: PageModel, queue: NSOperationQueue) -> NSOperation {
    let operation = NSBlockOperation()
    operation.addExecutionBlock { [weak self, unowned operation] in
      
      if operation.cancelled {
        return
      }
      
      if let strongSelf = self {
        
        let content: (ASDisplayNode, [IContainer]) = strongSelf.getContainerNodesWithPageModel(aPageModel)
        content.0.backgroundColor = UIColor.blackColor()
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
      aContainerNode.page = self
      aContainers.append(aContainerNode)
    }
    
    return (aContentNode, aContainers)
  }
  
  
  
  
  private func getContainerWithModel(aContainerModel: ContainerModel) -> ContainerNode {
    
    let info = getAContainerInfo(aContainerModel)
    
    let aContainerNode = ContainerNode(postion: info.0, size: info.1, rotation: info.2, aspectRatio: aspectRatio, aContainerModel: aContainerModel)
    
    let size = aContainerNode.measure(CGSize(width: CGFloat.max, height: CGFloat.max))
    aContainerNode.bounds.size = size
    aContainerModel.setOnScreenSize(size)
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
