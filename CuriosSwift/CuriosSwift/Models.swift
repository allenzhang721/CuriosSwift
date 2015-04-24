//
//  Models.swift
//  CuriosSwift
//
//  Created by 星宇陈 on 4/19/15.
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
    
    enum flipDirections {
        case ver, hor
    }
    
    enum flipTypes {
        case aa, bb
    }
    
    var Id = ""
    var width = 0
    var height = 0
    var title = ""
    var desc = ""
    var flipDirection: flipDirections = .ver
    var flipType: flipTypes = .aa
    var background = ""
    var backgroundMusic = ""
    var pagesPath = ""
    var autherID = ""
    var publishDate: NSDate!
    var pagesInfo: [[String:String]] = [[:]]
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
    
    //TODO: flipDirection
    
    //TODO: fliptypes
    
    //TODO: publishDate
    
    //TODO: pageModels
}

class PageModel: Model {
    
    var Id = ""
    var width = 0
    var height = 0
    var containers: [ContainerModel] = []
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
                    "Id" : "ID",
                 "width" : "PageWidth",
                "height" : "PageHeight",
            "containers" : "Containers"
        ]
    }
    
    //TODO: congtainers
}

class ContainerModel: Model {
    
    var Id = ""
    var x = 100.0
    var y = 100.0
    var width = 100.0 // bounds.width
    var height = 100.0 // bounds.height
    var rotation = 0.0
    var alpha = 0.0
    var editable = true
    var animations:[Animation] = []
    var behaviors: [Behavior] = []
    var effects: [Effect] = []
    var component: ComponentModel! = NoneContentModel()

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
    
    //TODO: animations
    
    //TODO: behaviors
    
    //TODO: effects
    
    //TODO: component
    
//    class func animaitonJSONTransformer() -> NSValueTransformer {
//        
//        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
//            "None":animations.None.rawValue,
//            "FadeIn":animations.FadeIn.rawValue,
//            "FadeOut":animations.FadeOut.rawValue
//            ])
//    }
//    
//    class func contentJSONTransformer() -> NSValueTransformer {
//        
//        let forwardBlock: MTLValueTransformerBlock! = {
//            (jsonDic: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in
//
//            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ComponentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
//            return something
//        }
//        
//        let reverseBlock: MTLValueTransformerBlock! = {
//            (contentModel: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
//            let something: AnyObject! = MTLJSONAdapter.JSONDictionaryFromModel(contentModel as! ComponentModel, error: error)
//            return something
//        }
//        
//        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
//    }
}

class Animation: Model {
    
    enum types {
        case None, Rotation, FlowUp
    }
    
    enum easeTypes {
        case  Linear, EaseIn, EaseOut, EaseInOut
    }
    
    var type: types = .None
    var delay: NSTimeInterval = 0
    var duration: NSTimeInterval = 0
    var repeat: Int = 0
    var easeType: easeTypes = .Linear
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
    
    //TODO: type
    
    //TODO: easeType
}

class Behavior: Model {
    
    enum EventType {
        case None, Click ,DoubleClick
    }
    
    enum FunctionType {
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
    
    //TODO: type
    
    //TODO: functionName
}

class Effect: Model {
    
    enum EffectType {
        case None, Shadow
    }
    
    var type: EffectType = .None
    var attributes: [String : String] = [:]
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            
            "type" : "EffectType",
      "attributes" : "EffectData"
        ]
    }
    
    //TODO: type
}

class ComponentModel: Model  {
    
    enum Type: String {
        case Text = "Text", Image = "Image", None = "None"
    }
    
    var type = "None"
    var attributes: [String : AnyObject] = [:]
    
    class func classForParsingJSONDictionary(JSONDictionary: [NSObject : AnyObject]!) -> AnyClass! {
        
        if let type = JSONDictionary["ComponentType"] as? NSString {
            
            switch type {
            case Type.Text.rawValue:
                
                return TextContentModel.self
                
            case Type.Image.rawValue:
                
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


