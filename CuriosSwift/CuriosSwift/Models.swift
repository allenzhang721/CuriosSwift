//
//  Models.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

class Model: MTLModel, MTLJSONSerializing {

    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [String: AnyObject]()
    }
}

class BookModel: Model {
    
    @objc enum FlipDirections: Int {
        case ver, hor
    }
    
    @objc  enum FlipTypes: Int {
        case aa, bb
    }
    
    var Id = UniqueIDString()
    var width = 640
    var height = 1008
    var title = "New Book"
    var desc = ""
    var flipDirection: FlipDirections = .ver
    var flipType: FlipTypes = .aa
    var background = ""
    var backgroundMusic = ""
    var pagesPath = "/Pages"
    var autherID = ""
    var publishDate: NSDate! = NSDate(timeIntervalSinceNow: 0)
    var pagesInfo: [[String : String]] = [[:]]
    var pageModels: [PageModel] = []
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
                "Id" : "ID",
             "width" : "MainWidth",
            "height" : "MainHeight",
             "title" : "MainTitle",
              "desc" : "MainDesc",
     "flipDirection" : "FlipDirection",
          "flipType" : "FlipType",
        "background" : "MainBackground",
   "backgroundMusic" : "MainMusic",
         "pagesPath" : "PagesPath",
          "autherID" : "AutherID",
       "publishDate" : "PublishDate",
         "pagesInfo" : "Pages"
        ]
    }
    
    // flipDirection
    class func flipDirectionJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "ver":FlipDirections.ver.rawValue,
            "hor":FlipDirections.hor.rawValue
            ])
    }
    
    // fliptypes
    class func flipTypeJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "aa":FlipTypes.aa.rawValue,
            "bb":FlipTypes.bb.rawValue
            ])
    }
    
    // publishDate
    class func publishDateJSONTransformer() -> NSValueTransformer {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let forwardBlock: MTLValueTransformerBlock! = {
            (dateStr: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
            return dateFormatter.dateFromString(dateStr as! String)
        }

        let reverseBlock: MTLValueTransformerBlock! = {
            (date: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
            return dateFormatter.stringFromDate(date as! NSDate)
        }

        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
    }
    
    // pageModels
    class func pageModelsJSONTransformer() -> NSValueTransformer {

        let forwardBlock: MTLValueTransformerBlock! = {
            (jsonArray: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in

//            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
            let something: AnyObject! = MTLJSONAdapter.modelsOfClass(PageModel.self, fromJSONArray: jsonArray as! [PageModel], error: nil)
            return something
        }

        let reverseBlock: MTLValueTransformerBlock! = {
            (pages: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
            let something: AnyObject! = MTLJSONAdapter.JSONArrayFromModels(pages as! [PageModel], error: nil)
            return something
        }

        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
    }
    
}

class PageModel: Model {
    
    var Id = UniqueIDString()
    var width: CGFloat = 640.0
    var height: CGFloat = 1008.0
    var containers: [ContainerModel] = []
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
                    "Id" : "ID",
                 "width" : "PageWidth",
                "height" : "PageHeight",
            "containers" : "Containers"
        ]
    }
    
    // congtainers
    class func containersJSONTransformer() -> NSValueTransformer {
        
        let forwardBlock: MTLValueTransformerBlock! = {
            (jsonArray: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
            
            //            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
            let something: AnyObject! = MTLJSONAdapter.modelsOfClass(ContainerModel.self, fromJSONArray: jsonArray as! [ContainerModel], error: nil)
            return something
        }
        
        let reverseBlock: MTLValueTransformerBlock! = {
            (containers: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
            let something: AnyObject! = MTLJSONAdapter.JSONArrayFromModels(containers as! [ContainerModel], error: nil)
            return something
        }
        
        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
    }
}

protocol containerListener {
    var lX: Dynamic<CGFloat> {get}
    var lY: Dynamic<CGFloat> {get}
    var lWidth: Dynamic<CGFloat> {get}
    var lHeight: Dynamic<CGFloat> {get}
    var lRotation: Dynamic<CGFloat> {get}
}

class ContainerModel: Model, containerListener {
    
    var Id = ""
    var x: CGFloat = (CGFloat(rand() % 300)) + 100 {
        didSet {
            lX.value = x
        }
    }
    var y: CGFloat = (CGFloat(rand() % 300)) + 100 {
        didSet {
            lY.value = y
        }
    }
    var width: CGFloat = (CGFloat(rand() % 300)) + 200  {
        didSet {
            lWidth.value = width
        }
    }// bounds.width
    var height: CGFloat = (CGFloat(rand() % 300)) + 300 {
        didSet {
            lHeight.value = height
        }
    } // bounds.height
    var rotation: CGFloat = 0.0 {
        didSet {
            lRotation.value = rotation
        }
    }
    var alpha: CGFloat = 1.0
    var editable = true
    var animations:[Animation] = []
    var behaviors: [Behavior] = []
    var effects: [Effect] = []
    var component: ComponentModel! = NoneContentModel()
    
    let lX: Dynamic<CGFloat>
    let lY: Dynamic<CGFloat>
    let lWidth: Dynamic<CGFloat>
    let lHeight: Dynamic<CGFloat>
    let lRotation: Dynamic<CGFloat>

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
        "behaviors" : "Behaviors",
          "effects" : "Effect",
        "component" : "Component"
        ]
    }
    
   override init!() {
    lX = Dynamic(x)
    lY = Dynamic(y)
    lWidth = Dynamic(width)
    lHeight = Dynamic(height)
    lRotation = Dynamic(rotation)
        super.init()
        
    }

    required init!(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
//        fatalError("init(dictionary:error:) has not been implemented")
        lX = Dynamic(x)
        lY = Dynamic(y)
        lWidth = Dynamic(width)
        lHeight = Dynamic(height)
        lRotation = Dynamic(rotation)
        super.init(dictionary: dictionaryValue, error: error)
        
    }
    
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
    class func behaviorsJSONTransformer() -> NSValueTransformer {
        
        let forwardBlock: MTLValueTransformerBlock! = {
            (jsonArray: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
            
            //            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
            let something: AnyObject! = MTLJSONAdapter.modelsOfClass(Behavior.self, fromJSONArray: jsonArray as! [Behavior], error: nil)
            return something
        }
        
        let reverseBlock: MTLValueTransformerBlock! = {
            (containers: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
            let something: AnyObject! = MTLJSONAdapter.JSONArrayFromModels(containers as! [Behavior], error: nil)
            return something
        }
        
        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
    }
    
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
        case None, Rotation, FlowUp
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
            "FlowUp":Types.FlowUp.rawValue
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

class ComponentModel: Model  {
    
    @objc enum Type: Int {
        case None, Text, Image
    }
    
    var type: Type = .None
    var attributes: [String : AnyObject] = [:]
    
    class func classForParsingJSONDictionary(JSONDictionary: [NSObject : AnyObject]!) -> AnyClass! {
        
        if let type = JSONDictionary["ComponentType"] as? NSString {
            
            switch type {
            case "Text":
                
                return TextContentModel.self
                
            case "Image":
                
                return ImageContentModel.self
            default:
                
                return NoneContentModel.self
                
            }
        } else {
            return NoneContentModel.self
        }
    }
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            
            "type" : "ComponentType",
      "attributes" : "ComponentData"
        ]
    }
    
    //TODO: type
    class func typeJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "None":Type.None.rawValue,
            "Text":Type.Text.rawValue,
            "Image":Type.Image.rawValue,
            ])
    }
}

class NoneContentModel: ComponentModel {
}

class ImageContentModel: ComponentModel {
}

class TextContentModel: ComponentModel {
}

extension MTLJSONAdapter {
    
    //    class func modelOfClass<T: MTLModel>(T.Type, fromJSONDictionary: [String: AnyObject]?) -> (T?, NSError?) {
    //        var error: NSError?
    //        let model = modelOfClass(T.self, fromJSONDictionary: fromJSONDictionary, error: &error) as? T
    //        return (model, error)
    //    }
    //
    //    class func modelOfClass<T: MTLModel>(T.Type, fromJSONDictionary: [String: AnyObject]?) -> T? {
    //
    //        let model = modelOfClass(T.self, fromJSONDictionary: fromJSONDictionary, error: nil) as? T
    //        return model
    //    }
    //
    //    class func modelsOfClass<T: MTLModel>(T.Type, fromJSONArray: [AnyObject]!) -> ([T]?, NSError?) {
    //        var error: NSError?
    //        let models = modelsOfClass(T.self, fromJSONArray: fromJSONArray, error: &error)
    //        return (models as? [T], error)
    //    }
}


