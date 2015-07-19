//
//  CUAnimationFactory.swift
//  PopAnimationDemo
//
//  Created by Emiaostein on 6/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import pop

enum EasingFunctionType {
    
    case
    EasingInBack,
    EasingOutBack,
    EasingInOutBack,
    EasingInBounce,
    EasingOutBounce,
    EasingInOutBounce,
    EasingInCirc,
    EasingOutCirc,
    EasingInOutCirc,
    EasingInCubic,
    EasingOutCubic,
    EasingInOutCubic,
    EasingInElastic,
    EasingOutElastic,
    EasingInOutElastic,
    EasingInExpo,
    EasingOutExpo,
    EasingInOutExpo,
    EasingInQuad,
    EasingOutQuad,
    EasingInOutQuad,
    EasingInQuart,
    EasingOutQuart,
    EasingInOutQuart,
    EasingInQuint,
    EasingOutQuint,
    EasingInOutQuint,
    EasingInSine,
    EasingOutSine,
    EasingInOutSine
}

class CUAnimationFactory: NSObject {
    
    typealias AnimationBlock = (currentTime: Double, duration: Double, currentValues: [Double], animationTarget: AnyObject) -> Void
    
    static let shareInstance = CUAnimationFactory()
    
    private var anmationing = false
    
    var animationStateListener = Dynamic(true)
    
    var completeBlock: (Bool -> Void)!

    
    func animation(aFromValue: [Double],_ aToValue: [Double],_ aDuration: Double, _ easingFunctionType: EasingFunctionType, _ aBlock: AnimationBlock) {
        
        self.pop_removeAnimationForKey("Preview")
        
//        let function = easingFuntionWithType(easingFunctionType)
      
        let aAnimation = POPCustomAnimation {(target, animation: POPCustomAnimation!) -> Bool in
            
            let t = animation.currentTime - animation.beginTime
            let d = aDuration
            
            assert(aFromValue.count == aToValue.count, "fromValue。count != toValue.count")
            if t < d {
                var values = [Double]()
                for (index, value) in enumerate(aFromValue) {
                    let from = value
                    let to = aToValue[index]
                    let b = from
                    let c = to - from
//                    let easFuncValue = function(t: t, b: b, c: c, d: d)
//                    values.append(easFuncValue)
                }
                
                aBlock(currentTime: t, duration: d, currentValues: values, animationTarget: target)
                return true
            } else {
                return false
            }
        }
        anmationing = true
        animationStateListener.value = false
        
        aAnimation.completionBlock = {[unowned self] (animatoin, completed) -> Void in
            
            self.anmationing = false
            self.animationStateListener.value = true
            
            if let com = self.completeBlock {
                com(true)
            }
        }
        
        self.pop_addAnimation(aAnimation, forKey: "Preview")
    }
    
    func cancelAnimation() {
        self.pop_removeAnimationForKey("Preview")
    }
    
    func isAnimationing() -> Bool {
        return anmationing
    }
}


