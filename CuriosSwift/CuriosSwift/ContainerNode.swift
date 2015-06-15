//
//  ContainerNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ContainerNode: ASDisplayNode, IContainer {
    
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
    
    private let containerModel: ContainerModel
    var component: IComponent!
    var componentNode: ASDisplayNode!
    private let aspectRatio: CGFloat
    
    init(postion: CGPoint, size: CGSize, rotation:CGFloat, aspectRatio theAspectRatio: CGFloat,aContainerModel: ContainerModel) {
        self.aspectRatio = theAspectRatio
        self.containerModel = aContainerModel
        
        super.init()
        position = postion
        bounds.size = size
        transform = CATransform3DMakeRotation(rotation, 0, 0, 1)
        component = containerModel.component.createComponent()
        
        if let aCom = component as? ASDisplayNode {
            println("addSubnode aCom = \(aCom)")
            addSubnode(aCom)
        }
    }
    
    func containAcontainer(aContainerModel: ContainerModel) -> Bool {
        
        return containerModel.isEqual(aContainerModel)
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
    
    // MARK: - IContainer
    
    func setAnimationWithName(name: String) {
        
        println("setAnimationName: \(name)")
        switch name {
            case "FadeIn":
                AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: position, toPosition: position, fromOpacity: 0, toOpacity: 1, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
                case "FloatIn":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: CGPoint(x: position.x, y: position.y + frame.height), toPosition: position, fromOpacity: 0, toOpacity: 1, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
                case "ZoomIn":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: position, toPosition: position, fromOpacity: 0, toOpacity: 1, fromScale: 0.2, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
                case "ScaleIn":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: position, toPosition: position, fromOpacity: 0, toOpacity: 1, fromScale: 2, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
                case "DropIn":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: CGPoint(x: position.x, y: 0-(frame.height / 2.0)), toPosition: position, fromOpacity: 1, toOpacity: 1, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
                case "SlideIn":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: CGPoint(x: 0-(frame.width / 2.0), y: position.y), toPosition: position, fromOpacity: 1, toOpacity: 1, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
                case "TeetertotterIn":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: position, toPosition: position, fromOpacity: 0, toOpacity: 1, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation + 270)
                case "FadeOut":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: position, toPosition: position, fromOpacity: 1, toOpacity: 0, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
                case "FloatOut":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition:position , toPosition: CGPoint(x: position.x, y: position.y + frame.height), fromOpacity: 1, toOpacity: 0, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
                case "ZoomOut":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: position, toPosition: position, fromOpacity: 1, toOpacity: 0, fromScale: 1, toScale: 0.2, fromRotation: containerRotation, toRotation: containerRotation)
                case "ScaleOut":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: position, toPosition: position, fromOpacity: 1, toOpacity: 0, fromScale: 1, toScale: 2, fromRotation: containerRotation, toRotation: containerRotation)
                case "DropOut":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: CGPoint(x: position.x, y: 504 + (frame.height / 2.0)), toPosition: position, fromOpacity: 1, toOpacity: 1, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
                case "SlideOut":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: CGPoint(x: 320 + (frame.width / 2.0), y: position.y), toPosition: position, fromOpacity: 1, toOpacity: 1, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation)
            case "TeetertotterOut":
                    AnimationFactory.shareInstance.addFadeInAnimation(view.layer, fromPosition: position, toPosition: position, fromOpacity: 1, toOpacity: 0, fromScale: 1, toScale: 1, fromRotation: containerRotation, toRotation: containerRotation + 270)
        default:
            return
        }
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
    
    func setResize(size: CGSize, center: CGPoint) {
        
        bounds.size = size
        position.x += center.x
        position.y += center.y
        containerModel.width = size.width / aspectRatio
        containerModel.height = size.height / aspectRatio
        containerModel.x = frame.origin.x / aspectRatio
        containerModel.y = frame.origin.y / aspectRatio
    }
    
    func setRotation(incrementAngle: CGFloat) {
        transform = CATransform3DMakeRotation(incrementAngle, 0, 0, 1)
        containerModel.rotation = incrementAngle
    }
}

// MARK: - private method
extension ContainerNode {
    
        override func layout() {
            for subNode in subnodes as! [ASDisplayNode] {
                subNode.frame = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)
            }
        }
    
}
