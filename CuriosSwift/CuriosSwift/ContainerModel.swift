//
//  ContainerModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class ContainerModel: Model {
    
    var Id = ""
    var x: CGFloat = (CGFloat(rand() % 300)) + 300
    var y: CGFloat = (CGFloat(rand() % 300)) + 500
    var width: CGFloat = (CGFloat(rand() % 80)) + 100  // bounds.width
    var height: CGFloat = (CGFloat(rand() % 80)) + 100  // bounds.height
    var rotation: CGFloat = 0.0
    var alpha: CGFloat = 1.0
    var editable = true
    var animations:[Animation] = []
//    var behaviors: [Behavior] = []
    var effects: [Effect] = []
    var component: ComponentModel! = NoneContentModel()
    
    //    let lX: Dynamic<CGFloat>
    //    let lY: Dynamic<CGFloat>
    //    let lWidth: Dynamic<CGFloat>
    //    let lHeight: Dynamic<CGFloat>
    //    let lRotation: Dynamic<CGFloat>
    
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
    
    //   override init!() {
    //    lX = Dynamic(x)
    //    lY = Dynamic(y)
    //    lWidth = Dynamic(width)
    //    lHeight = Dynamic(height)
    //    lRotation = Dynamic(rotation)
    //        super.init()
    //
    //    }
    
    //    required init!(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
    ////        fatalError("init(dictionary:error:) has not been implemented")
    //        lX = Dynamic(x)
    //        lY = Dynamic(y)
    //        lWidth = Dynamic(width)
    //        lHeight = Dynamic(height)
    //        lRotation = Dynamic(rotation)
    //        super.init(dictionary: dictionaryValue, error: error)
    //
    //    }
    
    // animations
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

class Animation: Model {
    
    @objc enum Types: Int {
        case None, Rotation, FloatUp
    }
    
    @objc enum EaseTypes: Int {
        case  Linear, EaseIn, EaseOut, EaseInOut
    }
    
    var type: Types = .None
    var delay: NSTimeInterval = 0
    var duration: NSTimeInterval = 0
    var repeat: Int = 0
    var easeType: EaseTypes = .Linear
    var attributes: [String : String] = [:]
    
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
            "Rotation":Types.Rotation.rawValue,
            "FloatUp":Types.FloatUp.rawValue
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

class Behavior: Model {
    
    @objc enum EventType: Int {
        case None, Click ,DoubleClick
    }
    
    @objc enum FunctionType: Int {
        case None, playMuisc
    }
    
    var eventType: EventType = .None
    var eventValue: Int = 1
    var eventId = ""
    var functionName: FunctionType = .None
    var functionValue: Int = 1
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            
            "eventType" : "EventName",
            "eventValue" : "EventValue",
            "eventId" : "ObjectID",
            "functionName" : "FunctionName",
            "functionValue" : "FunctionValue"
        ]
    }
    
    // eventType
    class func eventTypeJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "None":EventType.None.rawValue,
            "Click":EventType.Click.rawValue,
            "DoubleClick":EventType.DoubleClick.rawValue
            ])
    }
    
    // functionName
    class func functionNameJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "None":FunctionType.None.rawValue,
            "playMuisc":FunctionType.playMuisc.rawValue
            ])
    }
}

class Effect: Model {
    
    @objc enum EffectType: Int {
        case None, Shadow
    }
    
    var type: EffectType = .None
    var attributes: [String : AnyObject] = [:]
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            
            "type" : "EffectType",
            "attributes" : "EffectData"
        ]
    }
    
    // EffectType
    class func typeJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "None":EffectType.None.rawValue,
            "Shadow":EffectType.Shadow.rawValue
            ])
    }
}