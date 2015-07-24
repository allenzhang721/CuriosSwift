//
//  Animation.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class Animation: Model {
  
  @objc enum Types: Int {
    case None = 1, FadeIn, FloatIn, ZoomIn, ScaleIn, DropIn, SlideIn, TeetertotterIn, FadeOut, FloatOut, ZoomOut, ScaleOut, DropOut, SlideOut, TeetertotterOut
  }
  
  @objc enum EaseTypes: Int {
    case  Linear, EaseIn, EaseOut, EaseInOut
  }
  
  func name() -> String {
    switch type {
    case .None:
      return "None"
    case .FadeIn:
      return "FadeIn"
    case .FloatIn:
      return "FloatIn"
    case .ZoomIn:
      return "ZoomIn"
    case .ScaleIn:
      return "ScaleIn"
    case .DropIn:
      return "DropIn"
    case .SlideIn:
      return "SlideIn"
    case .TeetertotterIn:
      return "TeetertotterIn"
    case .FadeOut:
      return "FadeOut"
    case .FloatOut:
      return "FloatOut"
    case .ZoomOut:
      return "ZoomOut"
    case .ScaleOut:
      return "ScaleOut"
    case .DropOut:
      return "DropOut"
    case .SlideOut:
      return "SlideOut"
    case .TeetertotterOut:
      return "TeetertotterOut"
    default:
      return "None"
    }
  }
  
  
  var easeType: EaseTypes = .Linear
  var delay: NSTimeInterval = 0
  var type: Types = .None
  var repeat: Int = 1
  var attributes: [String : String] = [:]
  var duration: NSTimeInterval = 1000
  
  override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
    
    return [
      
      "type" : "AnimationType",
      "delay" : "AnimationDelay",
      "duration" : "AnimationDuration",
      "repeat" : "AnimationRepeat",
      "easeType" : "AnimationEaseType",
      "attributes" : "AnimationData"
    ]
  }
  
  // type
  class func typeJSONTransformer() -> NSValueTransformer {
    
    return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
      "None":Types.None.rawValue,
      "FadeIn":Types.FadeIn.rawValue,
      "FloatIn":Types.FloatIn.rawValue,
      "ZoomIn":Types.ZoomIn.rawValue,
      "ScaleIn":Types.ScaleIn.rawValue,
      "DropIn":Types.DropIn.rawValue,
      "SlideIn":Types.SlideIn.rawValue,
      "TeetertotterIn":Types.TeetertotterIn.rawValue,
      "FadeOut":Types.FadeOut.rawValue,
      "FloatOut":Types.FloatOut.rawValue,
      "ZoomOut":Types.ZoomOut.rawValue,
      "ScaleOut":Types.ScaleOut.rawValue,
      "DropOut":Types.DropOut.rawValue,
      "SlideOut":Types.SlideOut.rawValue,
      "TeetertotterOut":Types.TeetertotterOut.rawValue
      ])
  }
  
  // easeType
  class func easeTypeJSONTransformer() -> NSValueTransformer {
    
    return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
      "Linear":EaseTypes.Linear.rawValue,
      "EaseIn":EaseTypes.EaseIn.rawValue,
      "EaseOut":EaseTypes.EaseOut.rawValue,
      "EaseInOut":EaseTypes.EaseInOut.rawValue,
      ])
  }
}