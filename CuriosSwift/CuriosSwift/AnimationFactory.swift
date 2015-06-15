//
//  AnimationFactory.swift
//  CuriosSwift
//
//  Created by Emiaostein on 6/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class AnimationFactory {
    
    private var animationing: Bool = false
    static let shareInstance = AnimationFactory()
    
    func animating() -> Bool {
        return animationing
    }
//    None
//    FadeIn
    
//    func addAnimationWithName(name: String, layer: CALayer, fromPosition: CGPoint, toPosition: CGPoint, fromOpacity: CGFloat, toOpacity: CGFloat, fromRotation: CGFloat, toRotation: CGFloat) {
//        
//        switch name {
//            case "FadeIn":
//            
//        }
//        
//    }
    
    func addFadeInAnimation(layer: CALayer, fromPosition: CGPoint, toPosition: CGPoint, fromOpacity: CGFloat, toOpacity: CGFloat, fromScale: CGFloat, toScale: CGFloat,  fromRotation: CGFloat, toRotation: CGFloat){
        addFadeInAnimationCompletionBlock(layer, fromPosition: fromPosition, toPosition: toPosition, fromOpacity: fromOpacity, toOpacity: toOpacity, fromScale: fromScale, toScale: toScale, fromRotation: fromRotation, toRotation: toRotation, completionBlock: nil)
    }
    
    func addFadeInAnimationCompletionBlock(layer: CALayer, fromPosition: CGPoint, toPosition: CGPoint, fromOpacity: CGFloat, toOpacity: CGFloat, fromScale: CGFloat, toScale: CGFloat, fromRotation: CGFloat, toRotation: CGFloat, completionBlock: ((finished: Bool) -> Void)?){
//        if let completion = completionBlock{
//            var completionAnim : CABasicAnimation = CABasicAnimation(keyPath:"completionAnim")
//            completionAnim.duration = 0.998
//            completionAnim.delegate = self
//            completionAnim.setValue("FadeIn", forKey:"animId")
//            completionAnim.setValue(false, forKey:"needEndAnim")
//            layer.addAnimation(completionAnim, forKey:"FadeIn")
//            completionBlocks[layer.animationForKey("FadeIn")] = completionBlock
//        }
        
        var fillMode : String = kCAFillModeBackwards
        let scaleFraction = CGFloat(toScale - fromScale) / 2.0
        let rotationFraction = CGFloat(toRotation - fromRotation) / 2.0
        ////Layer animation
        var LayerOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
        LayerOpacityAnim.values         = [fromOpacity, toOpacity]
        LayerOpacityAnim.keyTimes       = [0, 1]
        LayerOpacityAnim.duration       = 1
        LayerOpacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
//
//        ////Layer animation
        var LayerPositionAnim            = CAKeyframeAnimation(keyPath:"position")
        LayerPositionAnim.values         = [NSValue(CGPoint: fromPosition), NSValue(CGPoint: toPosition)]
        LayerPositionAnim.keyTimes       = [0, 1]
        LayerPositionAnim.duration       = 1
        LayerPositionAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        ////Layer animation
        var rectangleTransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        rectangleTransformAnim.values   = [
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(fromScale, fromScale, 1), CATransform3DMakeRotation(CGFloat(fromRotation), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(fromScale + scaleFraction, fromScale + scaleFraction, 1), CATransform3DMakeRotation(CGFloat(fromRotation + rotationFraction), 0, 0, 1))),
            NSValue(CATransform3D: CATransform3DConcat(CATransform3DMakeScale(toScale, toScale, 1), CATransform3DMakeRotation(CGFloat(toRotation), 0, 0, 1)))]
        rectangleTransformAnim.keyTimes = [0, 0.5, 1]
        rectangleTransformAnim.duration = 1
        rectangleTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        
        var LayerFadeInAnim : CAAnimationGroup = QCMethod.groupAnimations([LayerOpacityAnim, LayerPositionAnim, rectangleTransformAnim], fillMode:fillMode)
        layer.addAnimation(LayerFadeInAnim, forKey:"LayerFadeInAnim")
    }
    
//    FloatIn
    
    
//    ZoomIn
//    ScaleIn
//    DropIn
//    SlideIn
//    TeetertotterIn
//    FadeOut
//    FloatOut
//    ZoomOut
//    ScaleOut
//    DropOut
//    SlideOut       
//    TeetertotterOut
}