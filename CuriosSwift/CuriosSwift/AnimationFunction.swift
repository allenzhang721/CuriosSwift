////
////  AnimationFunction.swift
////  CuriosSwift
////
////  Created by Emiaostein on 6/18/15.
////  Copyright (c) 2015 botai. All rights reserved.
////
//
import Foundation

class AnimationFunction {
  
  
  
  typealias easingFunction = (t: Double, b: Double, c: Double, d: Double) -> Double
  
  static func easingFuntionWithType(easingFuntionType: EasingFunctionType) -> easingFunction {
    switch easingFuntionType {
      
    case .Linear:
      return AnimationFunction.Linear
      
    case .EasingInBack:
      return AnimationFunction.EasingInBack
      
    case .EasingOutBack:
      return AnimationFunction.EasingOutBack
      
    case .EasingInOutBack:
      return AnimationFunction.EasingInOutBack
      
    case .EasingInBounce:
      return AnimationFunction.EasingInBounce
      
    case .EasingOutBounce:
      return AnimationFunction.EasingOutBounce
      
    case .EasingInOutBounce:
      return AnimationFunction.EasingInOutBounce
      
    case .EasingInCirc:
      return AnimationFunction.EasingInCirc
      
    case .EasingOutCirc:
      return AnimationFunction.EasingOutCirc
      
    case .EasingInOutCirc:
      return AnimationFunction.EasingInOutCirc
      
    case .EasingInCubic:
      return AnimationFunction.EasingInCubic
      
    case .EasingOutCubic:
      return AnimationFunction.EasingOutCubic
      
    case .EasingInOutCubic:
      return AnimationFunction.EasingInOutCubic
      
    case .EasingInElastic:
      return AnimationFunction.EasingInElastic
      
    case .EasingOutElastic:
      return AnimationFunction.EasingOutElastic
      
    case .EasingInOutElastic:
      return AnimationFunction.EasingInOutElastic
      
    case .EasingInExpo:
      return AnimationFunction.EasingInExpo
      
    case .EasingOutExpo:
      return AnimationFunction.EasingOutExpo
      
    case .EasingInOutExpo:
      return AnimationFunction.EasingInOutExpo
      
    case .EasingInQuad:
      return AnimationFunction.EasingInQuad
      
    case .EasingOutQuad:
      return AnimationFunction.EasingOutQuad
      
    case .EasingInOutQuad:
      return AnimationFunction.EasingInOutQuad
      
    case .EasingInQuart:
      return AnimationFunction.EasingInQuart
      
    case .EasingOutQuart:
      return AnimationFunction.EasingOutQuart
      
    case .EasingInOutQuart:
      return AnimationFunction.EasingInOutQuart
      
    case .EasingInQuint:
      return AnimationFunction.EasingInQuint
      
    case .EasingOutQuint:
      return AnimationFunction.EasingOutQuint
      
    case .EasingInOutQuint:
      return AnimationFunction.EasingInOutQuint
      
    case .EasingInSine:
      return AnimationFunction.EasingInSine
      
    case .EasingOutSine:
      return AnimationFunction.EasingOutSine
      
    case .EasingInOutSine:
      return AnimationFunction.EasingInOutSine
    }
  }
  
  static let Linear =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
//    let s = 1.70158
    t /= d
    return b + c * t
  }
  
  static let EasingInBack =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    let s = 1.70158
    t /= d
    return c * t * t * ((s + 1) * t - s) + b
  }
  
  static let EasingOutBack =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    let s = 1.70158
    t = t / d - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
  }
  
  static let EasingInOutBack =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    var s = 1.70158
    let k = 1.525
    t /= d / 2
    s *= k
    if (t < 1) {
      return c / 2 * (t * t * ((s + 1) * t - s)) + b
    }
    else {
      t -= 2;
      return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
    }
  }
  static let EasingInBounce =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    return c - EasingOutBounce(d - t, 0, c, d) + b
  }
  static let EasingOutBounce =  { (var t: Double, var b: Double, var c: Double, var d: Double) -> Double in
    
    let k = 2.75
    t /= d
    if (t) < (1.0 / k) {
      return c * (7.5625 * t * t) + b;
    }
    else if (t < (2 / k)) {
      t -= 1.5 / k;
      return c * (7.5625 * t * t + 0.75) + b;
    }
    else if (t < (2.5 / k)) {
      t -= 2.25 / k;
      return c * (7.5625 * t * t + 0.9375) + b;
    }
    else {
      t -= 2.625 / k;
      return c * (7.5625 * t * t + 0.984375) + b;
    }
  }
  static let EasingInOutBounce =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    if (t < d * 0.5) {
      return EasingInBounce(t * 2, 0, c, d) * 0.5 + b;
    }
    else {
      return EasingOutBounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b;
    }
  }
  static let EasingInCirc =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    t /= d
    return -c * (sqrt(1 - t * t) - 1) + b
  }
  static let EasingOutCirc =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    t = t / d - 1
    return c * sqrt(1 - t * t) + b
  }
  static let EasingInOutCirc =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    t /= (d/2)
    if (t <= 1) {
      return -c / 2 * (sqrt(1 - t * t) - 1) + b
    }
    else {
      t -= 2;
      return c / 2 * (sqrt(1 - t * t) + 1) + b
    }
  }
  static let EasingInCubic =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    t /= d
    return c * t * t * t + b
  }
  static let EasingOutCubic =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    t = t / d - 1
    return c * (t * t * t + 1) + b
  }
  static let EasingInOutCubic =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    t /= d / 2
    if (t < 1) {
      return c / 2 * t * t * t + b
    }
    
    t -= 2
    return c / 2 * (t * t * t + 2) + b
  }
  static let EasingInElastic =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    var s = 1.70158
    var p = 0.0
    var a = c
    if t == 0.0 {
      return b
    }
    t /= d
    if t == 1.0 {
      return b + c
    }
    if p == 0 {
      p = d * 0.3
    }
    if a < fabs(c) {
      a = c
      s = p / 4.0
    }
    else {
      s = p / (2 * 3.1419) * asin(c / a);
    }
    t--;
    return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * 3.1419) / p)) + b;
    
  }
  static let EasingOutElastic =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    var s = 1.70158
    var p = 0.0
    var a = c
    if (t == 0) {
      return b;
    }
    t /= d
    if t == 1.0 {
      return b + c
    }
    if p == 0.0 {
      p = d * 0.3
    }
    if a < fabs(c) {
      a = c
      s = p / 4.0
    }
    else {
      s = p / (2 * 3.1419) * asin(c / a)
    }
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * 3.1419) / p) + c + b
    
  }
  static let EasingInOutElastic =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    var s = 1.70158
    var p = 0.0
    var a = c
    if t == 0.0 {
      return b;
    }
    t /= d / 2
    if (t) == 2 {
      return b + c;
    }
    if p == 0.0 {
      p = d * (0.3 * 1.5)
    }
    if (a < fabs(c)) {
      a = c
      s = p / 4
    }
    else {
      s = p / (2 * 3.1419) * asin(c / a)
    }
    if (t < 1) {
      t--
      return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * 3.1419) / p)) + b
    }
    t--
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * 3.1419) / p) * 0.5 + c + b
    
  }
  static let EasingInExpo =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    return (t == 0.0) ? b : c * pow(2, 10 * (t / d - 1)) + b
  }
  static let EasingOutExpo =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    return (t == d) ? b + c : c * (-pow(2, -10 * t / d) + 1) + b
  }
  static let EasingInOutExpo =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    if (t == 0) {
      return b
    }
    else if (t == d) {
      return b + c
    }
    
    t /= d / 2
    
    if (t < 1) {
      return c / 2 * pow(2, 10 * (t - 1)) + b
    }
    else {
      return c / 2 * (-pow(2, -10 * --t) + 2) + b
    }
  }
  static let EasingInQuad =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    t /= d
    return c * t * t + b
  }
  static let EasingOutQuad =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    t /= d
    return -c * t * (t - 2) + b
  }
  static let EasingInOutQuad =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    t /= d / 2
    if (t < 1) {
      return c / 2 * t * t + b
    }
    t--
    return -c / 2 * (t * (t - 2) - 1) + b
  }
  static let EasingInQuart =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    t /= d
    return c * t * t * t * t + b
  }
  static let EasingOutQuart =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    t = t / d - 1
    return -c * (t * t * t * t - 1) + b
  }
  static let EasingInOutQuart =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    t /= d / 2
    if (t < 1) {
      return c / 2 * t * t * t * t + b
    }
    
    t -= 2
    return -c / 2 * (t * t * t * t - 2) + b
  }
  static let EasingInQuint =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    t /= d
    return c * t * t * t * t * t + b
  }
  static let EasingOutQuint =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    t = t / d - 1
    return c * (t * t * t * t * t + 1) + b
  }
  static let EasingInOutQuint =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    t /= d / 2
    if (t < 1) {
      return c / 2 * t * t * t * t * t + b
    }
    t -= 2;
    return c / 2 * (t * t * t * t * t + 2) + b
  }
  static let EasingInSine =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    return -c * cos(t / d * (M_PI / 2)) + c + b
  }
  static let EasingOutSine =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    return c * sin(t / d * (M_PI / 2)) + b
  }
  static let EasingInOutSine =  { (var t: Double,var b: Double, var c: Double, var d: Double) -> Double in
    
    return -c / 2 * (cos(M_PI * t / d) - 1) + b
  }

  
}