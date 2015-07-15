//
//  ContainerNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

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
        transform = CATransform3DMakeRotation(rotation, 0, 0, 1)
        component = containerModel.component.createComponent()
      
        if let aCom = component as? ASDisplayNode {
            addSubnode(aCom)
        }
      
      if aContainerModel.component is TextContentModel {
//        println("Node Init: Text_\(randID)")
      } else {
//        println("Node Init: Image_\(randID)")
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
    println("newSize = \(newSize)")
    containerModel.updateOnScreenSize(newSize)
  }
  
  override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
    
    if let subNode = component as? ASTextNode {
      
      let minTextSize = subNode.measure(constrainedSize)
      return CGSize(width: minTextSize.width, height: minTextSize.height + 10)
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
    
//    println("Node begain binding: \(randID)")
    
    containerModel.needUpdateSizeListener.bind("ContainerNode_\(randID)") {[weak self] need -> Void in
      
      if need {
          self?.updateSize()
      }
      
    }
    
    containerModel.updateSizeListener.bind("ContainerNode_\(randID)") {[weak self] size -> Void in

        self?.view.bounds.size.width = size.width
        self?.view.bounds.size.height = size.height
    }
    
    containerModel.centerChangeListener.bind("ContainerNode_\(randID)") {[weak self] postion -> Void in
      
      self?.view.center.x += postion.x
      self?.view.center.y += postion.y
    }
    
    containerModel.sizeChangeListener.bind("ContainerNode_\(randID)") {[weak self] size -> Void in
      
      self?.view.bounds.size.width += size.width
      self?.view.bounds.size.height += size.height
    }
    
    containerModel.rotationListener.bind("ContainerNode_\(randID)") {[weak self] angle -> Void in
      self?.view.transform = CGAffineTransformMakeRotation(angle)
    }
  }
  
  func unbindingContainerModel() {
    
    if !binding {
      return
    }
    
    binding = false
    
//    println("Node End binding: \(randID)")
//    println("ContainerNode_\(randID) unbindingContainerModel")
    containerModel.needUpdateSizeListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.updateSizeListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.centerChangeListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.sizeChangeListener.removeActionWithID("ContainerNode_\(randID)")
    containerModel.rotationListener.removeActionWithID("ContainerNode_\(randID)")
  }
  
  deinit {
//    println("Node Deinit: \(randID)")
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
            easeType = EasingFunctionType.EasingInBounce
        case "DropIn":
            yB = Double(-frame.height)
            easeType = EasingFunctionType.EasingOutBounce
        case "SlideIn":
            xB = Double(0 - frame.width)
            easeType = EasingFunctionType.EasingOutBack
        case "TeetertotterIn":
            alphaB = 0.0
            angleE = angleB + 270.0 * M_PI / 180.0
            easeType = EasingFunctionType.EasingOutBack
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
            easeType = EasingFunctionType.EasingInBounce
        case "DropOut":
            yE = Double(0 + 504)
            easeType = EasingFunctionType.EasingOutSine
        case "SlideOut":
            xE = Double(320 + frame.width)
            easeType = EasingFunctionType.EasingInBack
        case "TeetertotterOut":
            alphaE = 0.0
            angleE = angleB + 270.0 * M_PI / 180.0
            easeType = EasingFunctionType.EasingInBounce
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
            
            self.layer.opacity = 1.0
            self.layer.transform = CATransform3DConcat(CATransform3DConcat(CATransform3DMakeRotation(CGFloat(angleo), 0, 0, 1), CATransform3DMakeScale(1, 1, 1)), CATransform3DMakeTranslation(0, 0, 0))
        }
        
        containerModel.setAnimationWithName(name)
        page?.saveInfo()
    }
    
    func responderToLocation(location: CGPoint, onTargetView targetVew: UIView) -> Bool {
        let point = targetVew.convertPoint(location, toView: view)
        return CGRectContainsPoint(bounds, point)
    }
    
    func becomeFirstResponder() {
        component.iBecomeFirstResponder()
    }
    
    func resignFirstResponder() {
        component.iResignFirstResponder()
    }
    
    func isFirstResponder() -> Bool {
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
                if let aPage = page {
                    
                    
                    aPage.exchangeContainerFromIndex(currentIndex, toIndex: currentIndex + 1)
                }
                supernode.insertSubnode(self, atIndex: currentIndex + 1)
                return true
            }
            
        } else {
            if currentIndex == 0 {
                return false
            } else {
                if let aPage = page {
                    aPage.exchangeContainerFromIndex(currentIndex, toIndex: currentIndex - 1)
                }
                supernode.insertSubnode(self, atIndex: currentIndex - 1)
                return true
            }
        }
    }
    
    override func layout() {
        for subNode in subnodes as! [ASDisplayNode] {
            subNode.frame = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)
        }
    }
    
}
