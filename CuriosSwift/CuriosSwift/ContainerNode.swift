//
//  ContainerNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ContainerNode: ASDisplayNode, IContainer, ContainerModelDelegate {
    
    var containerSize: CGSize{
        get {
            return bounds.size
        }
    }
    var containerPostion: CGPoint{
        get {
            return position
        }
    }
    
    var containerRotation: CGFloat{
        get{
            return containerModel.rotation
        }
    }
    
    var animationName: String {
        get {
            
            if containerModel.animations.count > 0 {
                return containerModel.animations[0].name()
            } else {
                return "None"
            }
        }
    }
  
  var binding = false
  
  let randID: String
    
    let lockedListener = Dynamic<Bool>(false)
    
    let containerModel: ContainerModel
    var component: IComponent!
    var componentNode: ASDisplayNode!
    weak var page: IPage?
    private let aspectRatio: CGFloat
    
    init(postion: CGPoint, size: CGSize, rotation:CGFloat, aspectRatio theAspectRatio: CGFloat,aContainerModel: ContainerModel) {
        self.aspectRatio = theAspectRatio
        self.containerModel = aContainerModel
        randID = aContainerModel.Id
        super.init()
        containerModel.aspectio = theAspectRatio
        position = postion
        bounds.size = size
        alpha = containerModel.alpha
        transform = CATransform3DMakeRotation(rotation, 0, 0, 1)
      
        component = containerModel.component.createComponent()
      updateMask()
      
        if let aCom = component as? ASDisplayNode {
            addSubnode(aCom)
        }
      
      if aContainerModel.component is TextContentModel {
      } else {
      }
      
      aContainerModel.delegate = self
      
//      containerModel.selectedListener.bind("ContainerNode_\(randID)") {[unowned self] selected -> Void in
//        
//        if selected {
//          self.bindingContainerModel()
//        } else {
//          self.unbindingContainerModel()
//        }
//        
//      }

      
//      bindingContainerModel()
    }
  
  func updateSize() {
    let newSize = calculateSizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max))
    containerModel.updateOnScreenSize(newSize)
    updateSubSize()
  }
  
  func updateSubSize() {
    
    if let subNode = component as? ASTextNode {
  
      let minTextSize = subNode.measure(CGSize(width: CGFloat.max, height: CGFloat.max))
      let minContainerWidth = bounds.width
      let minContainerHeight = bounds.height
      let subNodeX = (minContainerWidth) / 2.0
      let subNodeY = (minContainerHeight) / 2.0
//      let subFrame = CGRect(origin: , size: )
      subNode.position = CGPoint(x: subNodeX, y: subNodeY)
      subNode.bounds.size = minTextSize
//      debugPrint.p("minTextSize = \(minTextSize) \n subNodeFrame = \(subNode.frame) \n bounds = \(bounds)")
    }
    
  }
  
  override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
    
    if let subNode = component as? ASTextNode {
      
      let minTextSize = subNode.measure(constrainedSize)
//      let ratio = minTextSize.width / minTextSize.height
//      debugPrint.p("minTextSize = \(minTextSize) /n subNodeFrame = \(subNode.frame)")
      let minContainerWidth = minTextSize.width < 30.0 ? 30.0 : minTextSize.width
      let minContainerHeight = minTextSize.height < 30.0 ? 30.0 : minTextSize.height
//      let subNodeX = (minContainerWidth - minTextSize.width) / 2.0
//      let subNodeY = (minContainerHeight - minTextSize.height) / 2.0
//      let subFrame = CGRect(origin: CGPoint(x: subNodeX, y: subNodeY), size: minTextSize)
//      subNode.frame = subFrame
      
      let size = CGSize(width: minContainerWidth, height: minContainerHeight + 10)
      return size
//      return CGSize(width: minTextSize.width, height: minTextSize.height + 10)
    } else {
      return bounds.size
    }
    
  }
  
    func containAcontainer(aContainerModel: ContainerModel) -> Bool {
        
        return containerModel.isEqual(aContainerModel)
    }
  
  func bindingContainerModel() {
    
    if binding {
      return
    }
    
    binding = true
    
    containerModel.levelChangedListener.bind("ContainerNode_\(randID)") {[weak self] forward -> Void in
      
      if forward {
        self?.sendForwoard()
      } else {
        self?.sendBack()
      }
    }
    
    containerModel.animationNameListener.bind("ContainerNode_\(randID)") {[weak self] animationName -> Void in
      
        self?.setAnimationWithName(animationName)
      
    }
    
    containerModel.needUpdateSizeListener.bind("ContainerNode_\(randID)") {[weak self] need -> Void in
      
      if need {
          self?.updateSize()
      }
      
    }
    
    containerModel.updateSizeListener.bind("ContainerNode_\(randID)") {[weak self] size -> Void in

        self?.view.bounds.size.width = size.width
        self?.view.bounds.size.height = size.height
      
      let origin = self?.frame.origin
      self?.containerModel.setOnScreenOrigin(origin!)
      
    }
    
    containerModel.centerChangeListener.bind("ContainerNode_\(randID)") {[weak self] postion -> Void in
      
      self?.view.center.x += postion.x
      self?.view.center.y += postion.y
    }
    
    containerModel.sizeChangeListener.bind("ContainerNode_\(randID)") {[weak self] size -> Void in
      
      self?.bounds.size.width += size.width
      self?.bounds.size.height += size.height
      
      self?.updateSubSize()
      
      if let strongself = self where strongself.updateMask() {

      }
      
    }
    
    containerModel.rotationListener.bind("ContainerNode_\(randID)") {[weak self] angle -> Void in
      self?.view.transform = CGAffineTransformMakeRotation(angle)
    }
    
    containerModel.maskTypeListener.bind("ContainerNode_\(randID)") {[weak self] maskType -> Void in
      if let strongself = self where strongself.updateMask() {
      }
//      self?.view.transform = CGAffineTransformMakeRotation(angle)
    }
  }
  
  func unbindingContainerModel() {
    
    if !binding {
      return
    }
    
    binding = false
    
    containerModel.levelChangedListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.animationNameListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.needUpdateSizeListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.updateSizeListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.centerChangeListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.sizeChangeListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.rotationListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.maskTypeListener.removeActionWithID("ContainerNode_\(randID)")
  }
  
  deinit {
    containerModel.selectedListener.removeActionWithID("ContainerNode_\(randID)")
    unbindingContainerModel()
  }
    
    func addAnimation() {
        
        var fillMode : String = kCAFillModeForwards
        
        ////Layer animation
        var layerPositionAnim            = CAKeyframeAnimation(keyPath:"position")
        layerPositionAnim.values         = [NSValue(CGPoint: position), NSValue(CGPoint: CGPointMake(392.09, 284))]
        layerPositionAnim.keyTimes       = [0, 1]
        layerPositionAnim.duration       = 1
        layerPositionAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        ////Layer animation
        var layerOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        layerOpacityAnim.values         = [1, 0]
        layerOpacityAnim.keyTimes       = [0, 1]
        layerOpacityAnim.duration       = 1
        layerOpacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        var layerFadeOutAnim : CAAnimationGroup = QCMethod.groupAnimations([layerPositionAnim, layerOpacityAnim], fillMode:fillMode)
        self.layer.addAnimation(layerFadeOutAnim, forKey:"layerFadeOutAnim")
    }
  
  
  
  
  // MARK: - containerModel delegate
  func containerModel(model: ContainerModel, selectedDidChanged selected: Bool) {
    
    if selected {
      bindingContainerModel()
    } else {
      unbindingContainerModel()
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
    
    // MARK: - IContainer
    
    func setAnimationWithName(name: String) {
        
        let center = position
        let width = 320
        let height = 40
        let angleo = Double(containerModel.rotation)
        var alphaB = 1.0; var alphaE = 1.0
        var angleB = angleo; var angleE = angleo
        var yB = 0.0; var yE = 0.0
        var xB = 0.0; var xE = 0.0
        var scaleB = 1.0; var scaleE = 1.0
        var easeType = EasingFunctionType.EasingInBack
        let duration = 1.0
        var fromValue = [Double]()
        var toValue = [Double]()
        
        switch name {
        case "FadeIn":
            alphaB = 0.0
            easeType = EasingFunctionType.EasingInBack
        case "FloatIn":
            alphaB = 0.0
            yB = Double(frame.height)
            easeType = EasingFunctionType.EasingInSine
        case "ZoomIn":
            alphaB = 0.0
            scaleB = 0.1
            easeType = EasingFunctionType.EasingOutBounce
        case "ScaleIn":
            alphaB = 0.0
            scaleB = 2.0
            easeType = EasingFunctionType.Linear
        case "DropIn":
            yB = Double(-supernode.frame.height)
            easeType = EasingFunctionType.EasingOutBounce
        case "SlideIn":
            xB = Double(0 - supernode.frame.width)
            easeType = EasingFunctionType.EasingOutBack
        case "TeetertotterIn":
            alphaB = 0.0
            angleE = angleB + 720.0 * M_PI / 180.0
            easeType = EasingFunctionType.Linear
        case "FadeOut":
            alphaE = 0.0
            easeType = EasingFunctionType.EasingInBack
        case "FloatOut":
            alphaE = 0.0
            yE = Double(frame.height)
            easeType = EasingFunctionType.EasingInSine
        case "ZoomOut":
            alphaE = 0.0
            scaleE = 0.1
            easeType = EasingFunctionType.EasingInBack
        case "ScaleOut":
            alphaE = 0.0
            scaleE = 2.0
            easeType = EasingFunctionType.Linear
        case "DropOut":
            yE = Double(0 + 504)
            easeType = EasingFunctionType.EasingOutSine
        case "SlideOut":
            xE = Double(frame.width + supernode.frame.width)
            easeType = EasingFunctionType.EasingInBack
        case "TeetertotterOut":
            alphaE = 0.0
            angleE = angleB + 720.0 * M_PI / 180.0
            easeType = EasingFunctionType.Linear
        default:
            return
        }
        fromValue = [
            alphaB,
            angleB,
            yB,
            xB,
            scaleB
        
        ]
        toValue = [
            alphaE,
            angleE,
            yE,
            xE,
            scaleE
        ]
        
        CUAnimationFactory.shareInstance.animation(fromValue, toValue, duration, easeType) { [unowned self] (currentTime, duration, currentValues, animationTarget) -> Void in
            
            let alpha = Float(currentValues[0])
            let angle = CGFloat(currentValues[1])
            let y     = CGFloat(currentValues[2])
            let x     = CGFloat(currentValues[3])
            let scale = CGFloat(currentValues[4])
            
            self.layer.opacity = alpha
            self.layer.transform = CATransform3DConcat(CATransform3DConcat(CATransform3DMakeRotation(angle, 0, 0, 1), CATransform3DMakeScale(scale, scale, 1)), CATransform3DMakeTranslation(x, y, 0))
        }
        
        CUAnimationFactory.shareInstance.completeBlock = { finished in
          
          if finished {
            self.layer.opacity = 1.0
            self.layer.transform = CATransform3DConcat(CATransform3DConcat(CATransform3DMakeRotation(CGFloat(angleo), 0, 0, 1), CATransform3DMakeScale(1, 1, 1)), CATransform3DMakeTranslation(0, 0, 0))
          }
        }
        
//        containerModel.setAnimationWithName(name)
//        page?.saveInfo()
    }
    
    func responderToLocation(location: CGPoint, onTargetView targetVew: UIView) -> Bool {
        let point = targetVew.convertPoint(location, toView: view)
        return CGRectContainsPoint(bounds, point)
    }
    
    func abecomeFirstResponder() {
        component.iBecomeFirstResponder()
    }
    
    func aresignFirstResponder() {
        component.iResignFirstResponder()
    }
    
    func aisFirstResponder() -> Bool {
        return component.iIsFirstResponder()
    }
    
    func setTransation(translation: CGPoint) {
        
        self.position.x += translation.x
        self.position.y += translation.y
        containerModel.x += translation.x / aspectRatio
        containerModel.y += translation.y / aspectRatio
    }
  
    
    func sendForwoard() -> Bool {
        
        return sendToForwardOrBack(true)
    }
    func sendBack() -> Bool {
        
        return sendToForwardOrBack(false)
    }
    
    func lockLayer() -> Bool {
        
         lockedListener.value = !lockedListener.value
        return lockedListener.value
    }
    
    func getSnapshotImageAfterScreenUpdate(_ afterScreenUpdate: Bool = false) -> UIImage! {
        
       return view.snapshotImageAfterScreenUpdate(afterScreenUpdate)
    }
    
    func removed() {
        
        if let aPage = page {
            containerModel.removed()
        }
    }
}

// MARK: - Interface
extension ContainerNode: MaskableInterface {
  
  func updateMask() -> Bool {
    
    if let maskType = containerModel.maskType, let maskAttribute = MasksManager.maskTypes[maskType]  where !maskType.isEmpty && containerModel.component is ImageContentModel {
      var rect = bounds
      if maskAttribute.fixed {
//        let ratio = min(bounds.width / maskAttribute.width, bounds.height / maskAttribute.height)
        let size = maskAttribute.sizeToFit(rect.size)
        let origin = CGPointMake((bounds.width - size.width) / 2.0, (bounds.height - size.height) / 2.0)
          rect = CGRect(origin: origin, size: size)
      }
      
      if let shapeMask = view.layer.mask as? CAShapeLayer {
        shapeMask.path = MasksManager.bezierPathWithMask(maskType, atFrame: rect).CGPath
      } else {
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.path = MasksManager.bezierPathWithMask(maskType, atFrame: rect).CGPath
        view.layer.mask = layer
      }
      
      return true
    } else {
      return false
    }
  }
}



// MARK: - private method
extension ContainerNode {
    
    private func currentLayerIndex() -> Int {
        
        let nodes = supernode.subnodes
        
        for (index, subNode) in enumerate(nodes) {
            
            if subNode as! NSObject == self {
                
                return index
            }
        }
        
        assert(false, "this node is has no super node")
        return -1
    }
    
    private func sendToForwardOrBack(forward: Bool) -> Bool {
        let currentIndex = currentLayerIndex()
        let layoutCount = supernode.subnodes.count

        if forward {
            if currentIndex == layoutCount - 1 {
                return false
            } else {
                supernode.insertSubnode(self, atIndex: currentIndex + 1)
                return true
            }
            
        } else {
            if currentIndex == 0 {
                return false
            } else {
                supernode.insertSubnode(self, atIndex: currentIndex - 1)
                return true
            }
        }
    }
    
    override func layout() {
        for subNode in subnodes as! [ASDisplayNode] {
          if let textNode = subNode as? ASTextNode {
            let size = textNode.measure(CGSize(width: CGFloat.max, height: CGFloat.max))
            let x = (bounds.width - size.width) / 2.0
            let y = (bounds.height - size.height) / 2.0
            textNode.frame = CGRect(x: x, y: y, width: size.width, height: size.height + 10)
//            containerModel.component
          } else {
            subNode.frame = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)
          }
          
        }
    }
  
}
