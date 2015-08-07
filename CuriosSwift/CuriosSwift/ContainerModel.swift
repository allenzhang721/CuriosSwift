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

protocol ContainerModelSuperEditDelegate: NSObjectProtocol {
  
  func containerModelDidUpdate(model: ContainerModel)
  func containerModel(model: ContainerModel, levelDidChanged sendForward: Bool) -> Bool
  
}

class ContainerModel: Model, ComponentModelDelegate {
  
  let boundsSlope = "com.botai.Curios.ContainerModel.boundsSlope"
  let metaDataSlope = "com.botai.Curios.ContainerModel.metaDataSlope"
    
  struct Slope {
      
      // ax - by = 0  a > 0, b > 0  a = height, b = width
  
      let a: CGFloat
      let b: CGFloat
      
      func distanceFromPoint(point: CGPoint) -> CGFloat {
          
          return fabs(a * point.x - b * point.y) / sqrt(pow(a, 2) + pow(b, 2))
      }
    
    func retriveCorrectPointByY(y: CGFloat) -> CGPoint {
      
      let x = (b * y) / a
      return CGPoint(x: x, y: y)
    }
    
    func retriveCorrectPointByX(x: CGFloat) -> CGPoint {
      
      let y = (a * x) / b
      return CGPoint(x: x, y: y)
    }
  }
  
  // json
  var Id = ""
  var x: CGFloat = 0
  var y: CGFloat = 0
  var width: CGFloat =  300  // bounds.width
  var height: CGFloat =  300  // bounds.height
  var containerAngle: CGFloat = 0.0
  var rotation: CGFloat {
    
    get {
      return containerAngle * angleToRan
    }
    
    set {
      containerAngle = newValue * ranToAngle
    }
  }
  
  var slopes = [String:Slope]()
    
  var alpha: CGFloat = 1.0
  var editable = true
  var animations:[Animation] = []
  //    var behaviors: [Behavior] = []
  var effects: [Effect] = []
  var component: ComponentModel! = NoneContentModel()
  
  var locked: Bool {
    
    get {
      return !editable
    }
    
    set {
      editable = !newValue
    }
    
  }
  var selected: Bool = false
  weak var delegate: ContainerModelDelegate?
  weak var editDelegate: ContainerModelSuperEditDelegate?
  
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
  var levelChangedListener = Dynamic(true)
  var lockChangedListener = Dynamic(false)
  
  
  required init!(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
    super.init(dictionary: dictionaryValue, error: error)
    
    component.editDelegate = self
    
    
  }
  
  override init!() {
    super.init()
  }
  
  func updateSlopes() {
    
    let currentSlope = Slope(a: height, b: width)
    slopes[boundsSlope] = currentSlope
    
    if let imageComponent = component as? ImageContentModel,
        let imageSize = imageComponent.retriveImageSize()
    {
      let originSlope = Slope(a: imageSize.height, b: imageSize.width)
      slopes[metaDataSlope] = originSlope
    }
  }
  
  func retriveSlopeCorrectPoint(nextPoint: CGPoint) -> CGPoint? {  // in container's coordinate
    
    if slopes.count <= 0 {
      return nil
    }
    
    for (key, slope) in slopes {
      
      if slope.distanceFromPoint(nextPoint) <= 3.5 {
        return slope.retriveCorrectPointByY(nextPoint.y)
      }
    }
    
    return nil
  }
  
  
  func componentModelDidUpdate(model: ComponentModel) {
    editDelegate?.containerModelDidUpdate(self)
  }
  
  func setLockChanged(lock: Bool) {
    
    if locked != lock {
      locked = lock
      lockChangedListener.value = lock
      editDelegate?.containerModelDidUpdate(self)
    }
  }
  
  func setLevelChanged(sendForward: Bool) {
    
    if let aDelegate = editDelegate where !locked {
      if aDelegate.containerModel(self, levelDidChanged: sendForward) {
        levelChangedListener.value = sendForward
      }
    } else {
      println("ContainerModel not set Editting Delegate")
    }
    
  }
  
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
    
    editDelegate?.containerModelDidUpdate(self)
  }
  
  func setOnScreenSize(size: CGSize) {
    
//    sizeListener.value = size
    
    width = size.width / aspectio
    height = size.height / aspectio
    
//    editDelegate?.containerModelDidUpdate(self)
  }
  
  func setOnScreenOrigin(point: CGPoint) {
    
    x = point.x / aspectio
    y = point.y / aspectio
    
    editDelegate?.containerModelDidUpdate(self)
  }
  
  func setOriginChange(point: CGPoint) {
    x += point.x / aspectio
    y += point.y / aspectio
    
    editDelegate?.containerModelDidUpdate(self)
  }
  
  func setCenterChange(point: CGPoint) {
    
    centerChangeListener.value = point
  }
  
  func setSizeChange(size: CGSize) {
    
    sizeChangeListener.value = size
    
    width += size.width / aspectio
    height += size.height / aspectio
    
    editDelegate?.containerModelDidUpdate(self)
  }
  
//  struct correctRange {
//    let correctPoint: CGFloat = 0.0
//    let distance: CGFloat = 1.5 * angleToRan
//    
//    func check(input: CGFloat) -> (CGFloat, Bool) {
//      if fabs(input - correctPoint) <= distance {
//        return (correctPoint, true)
//      } else {
//        return (input, false)
//      }
//    }
//  }
  

  
  func setAngleChange(angle: CGFloat) {

    let newAngle = (angle + rotation) % CGFloat((2 * M_PI))
      rotationListener.value = newAngle
      rotation = newAngle
    
    debugPrint.p("angle = \(rotation)")
    
    let check0 = CheckItem(correctPoint: 0.0, distance: 1.25 * angleToRan)
//    let check45 = CheckItem(correctPoint: 45.0 * angleToRan, distance: 1.25 * angleToRan)
    let check90 = CheckItem(correctPoint: 90.0 * angleToRan, distance: 1.25 * angleToRan)
//    let check135 = CheckItem(correctPoint: 135.0 * angleToRan, distance: 1.25 * angleToRan)
    let check180 = CheckItem(correctPoint: 180.0 * angleToRan, distance: 1.25 * angleToRan)
    let check270 = CheckItem(correctPoint: 270.0 * angleToRan, distance: 1.25 * angleToRan)
    
    let checkm90 = CheckItem(correctPoint: -90.0 * angleToRan, distance: 1.25 * angleToRan)
    //    let check135 = CheckItem(correctPoint: 135.0 * angleToRan, distance: 1.25 * angleToRan)
    let checkm180 = CheckItem(correctPoint: -180.0 * angleToRan, distance: 1.25 * angleToRan)
    let checkm270 = CheckItem(correctPoint: -270.0 * angleToRan, distance: 1.25 * angleToRan)
    
    
    let result = rotation >= 0.0 ? rotation.check(check0).check(check90).check(check180).check(check270) : rotation.check(check0).check(checkm90).check(checkm180).check(checkm270)
    
    
//    if an.1 {
      rotationListener.value = result
      rotation = result
//    }
    
      editDelegate?.containerModelDidUpdate(self)
  }
  
  override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
    
    return [
      "Id" : "ID",
      "x" : "ContainerX",
      "y" : "ContainerY",
//      "locked" : "Editable",
      "width" : "ContaienrWidth",
      "height" : "ContainerHeight",
      "containerAngle" : "ContainerRotation",
      "alpha" : "ContainerAplha",
      "editable" : "Editable",
      "animations" : "Animations",
//      "behaviors" : "Behaviors",
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
    
    if animations.count > 0 {
      
      let firstAnimation = animations[0]
        if firstAnimation.name() == name {
          editDelegate?.containerModelDidUpdate(self)
        }
    }
    
    
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





