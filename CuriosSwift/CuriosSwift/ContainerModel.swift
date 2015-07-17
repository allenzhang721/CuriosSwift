//
//  ContainerModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

protocol ContainerModelDelegate: NSObjectProtocol {
  
  func containerModel(model: ContainerModel, selectedDidChanged selected: Bool)
}

class ContainerModel: Model {
  
  var Id = ""
  var x: CGFloat = 0
  var y: CGFloat = 0
  var width: CGFloat =  300  // bounds.width
  var height: CGFloat =  300  // bounds.height
  var rotation: CGFloat = 0.0
  var alpha: CGFloat = 1.0
  var editable = true //
  var locked = false
  var animations:[Animation] = []
  //    var behaviors: [Behavior] = []
  var effects: [Effect] = []
  var component: ComponentModel! = NoneContentModel()
  var selected: Bool = false
  weak var delegate: ContainerModelDelegate?
  
  var aspectio: CGFloat = 1.0
  
  // Observers
  var centerChangeListener = Dynamic(CGPointZero)
  var sizeChangeListener = Dynamic(CGSizeZero)
  var rotationListener = Dynamic(CGFloat(0))
  var sizeListener = Dynamic(CGSizeZero)
  var updateSizeListener = Dynamic(CGSizeZero)
  var needUpdateSizeListener = Dynamic(false)
  var selectedListener = Dynamic(false)
  var animationNameListener = Dynamic("None")
  
  func setSelectedState(select: Bool) {
    
    selected = select
    delegate?.containerModel(self, selectedDidChanged: selected)
  }
  
  func needUpdateOnScreenSize(need: Bool) {
    
    needUpdateSizeListener.value = need
  }
  
  func updateOnScreenSize(size: CGSize) {
    
    updateSizeListener.value = size
    
    width = size.width / aspectio
    height = size.height / aspectio
  }
  
  func setOnScreenSize(size: CGSize) {
    
//    sizeListener.value = size
    
    width = size.width / aspectio
    height = size.height / aspectio
  }
  
  func setOriginChange(point: CGPoint) {
    x += point.x / aspectio
    y += point.y / aspectio
  }
  
  func setCenterChange(point: CGPoint) {
    
    centerChangeListener.value = point
  }
  
  func setSizeChange(size: CGSize) {
    
    sizeChangeListener.value = size
    
    width += size.width / aspectio
    height += size.height / aspectio
  }
  
  func setAngleChange(angle: CGFloat) {
    
    let newAngle = angle + rotation
    rotationListener.value = newAngle
    rotation = newAngle
  }
  
  override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
    
    return [
      "Id" : "ID",
      "x" : "ContainerX",
      "y" : "ContainerY",
      "width" : "ContaienrWidth",
      "height" : "ContainerHeight",
      "rotation" : "ContainerRotation",
      "alpha" : "ContainerAplha",
      "editable" : "Editable",
      "animations" : "Animations",
      //            "behaviors" : "Behaviors",
      "effects" : "Effects",
      "component" : "Component"
    ]
  }
  
  // animations
  
  func removed() {
    
    component.removed()
  }
  
  func setAnimationWithName(name: String) {
    
    let animation = Animation()
    
    switch name {
    case "FadeIn":
      animation.type = .FadeIn
    case "FloatIn":
      animation.type = .FloatIn
    case "ZoomIn":
      animation.type = .ZoomIn
    case "ScaleIn":
      animation.type = .ScaleIn
    case "DropIn":
      animation.type = .DropIn
    case "SlideIn":
      animation.type = .SlideIn
    case "TeetertotterIn":
      animation.type = .TeetertotterIn
    case "FadeOut":
      animation.type = .FadeOut
    case "FloatOut":
      animation.type = .FloatOut
    case "ZoomOut":
      animation.type = .ZoomOut
    case "ScaleOut":
      animation.type = .ScaleOut
    case "DropOut":
      animation.type = .DropOut
    case "SlideOut":
      animation.type = .SlideOut
    case "TeetertotterOut":
      animation.type = .TeetertotterOut
    default:
      animation.type = .None
    }
    
    animations = [animation]
    
    animationNameListener.value = name
  }
  
  class func animationsJSONTransformer() -> NSValueTransformer {
    
    let forwardBlock: MTLValueTransformerBlock! = {
      (jsonArray: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
      
      //            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
      let something: AnyObject! = MTLJSONAdapter.modelsOfClass(Animation.self, fromJSONArray: jsonArray as! [Animation], error: nil)
      return something
    }
    
    let reverseBlock: MTLValueTransformerBlock! = {
      (containers: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
      let something: AnyObject! = MTLJSONAdapter.JSONArrayFromModels(containers as! [Animation], error: nil)
      return something
    }
    
    return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
  }
  
  // behaviors
  //    class func behaviorsJSONTransformer() -> NSValueTransformer {
  //
  //        let forwardBlock: MTLValueTransformerBlock! = {
  //            (jsonArray: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
  //
  //            //            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
  //            let something: AnyObject! = MTLJSONAdapter.modelsOfClass(Behavior.self, fromJSONArray: jsonArray as! [Behavior], error: nil)
  //            return something
  //        }
  //
  //        let reverseBlock: MTLValueTransformerBlock! = {
  //            (Behaviors: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
  //            let something: AnyObject! = MTLJSONAdapter.JSONArrayFromModels(Behaviors as! [Behavior], error: nil)
  //            return something
  //        }
  //
  //        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
  //    }
  
  // effects
  class func effectsJSONTransformer() -> NSValueTransformer {
    
    let forwardBlock: MTLValueTransformerBlock! = {
      (jsonArray: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
      
      //            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
      let something: AnyObject! = MTLJSONAdapter.modelsOfClass(Effect.self, fromJSONArray: jsonArray as! [Effect], error: nil)
      return something
    }
    
    let reverseBlock: MTLValueTransformerBlock! = {
      (containers: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
      let something: AnyObject! = MTLJSONAdapter.JSONArrayFromModels(containers as! [Effect], error: nil)
      return something
    }
    
    return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
  }
  
  // component
  class func componentJSONTransformer() -> NSValueTransformer {
    
    let forwardBlock: MTLValueTransformerBlock! = {
      (jsonDic: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
      
      let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
      return something
    }
    
    let reverseBlock: MTLValueTransformerBlock! = {
      (componentModel: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
      let something: AnyObject! = MTLJSONAdapter.JSONDictionaryFromModel(componentModel as! ComponentModel, error: error)
      return something
    }
    
    return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
  }
}





