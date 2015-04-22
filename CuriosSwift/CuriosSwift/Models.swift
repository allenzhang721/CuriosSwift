//
//  Models.swift
//  CuriosSwift
//
//  Created by 星宇陈 on 4/19/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit
import Mantle

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

class Model: MTLModel, MTLJSONSerializing {
    
    struct jsonGeometryKey {
        static let size = "size" + "."
        static let center = "center" + "."
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [String: AnyObject]()
    }
}

class BookModel: Model {
    var pages: [PageModel] = []
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [String: AnyObject]()
    }
}

class PageModel: Model {
    var width = 0
    var height = 0
    var items: [ItemModel] = []
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            "width" : jsonGeometryKey.size + "width",
            "height" : jsonGeometryKey.size + "height"
        ]
    }
}


class ItemModel: Model {
    
    @objc enum animations: Int {
        case None, FadeIn, FadeOut
    }
    
    var x = 100.0 // center.x
    var y = 100.0 // center.y
    var width = 100.0 // size.width
    var height = 100.0 // size.height
    var rotation = 0.0
    var editable = true
    var animation :animations = .None
    var content = NoneContentModel()
    
    override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        
        return [
            
            "x" : jsonGeometryKey.center + "x",
            "y" : jsonGeometryKey.center + "y",
            "width" : jsonGeometryKey.size + "width",
            "height" : jsonGeometryKey.size + "height"
        ]
    }
    
    class func animaitonJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "None":animations.None.rawValue,
            "FadeIn":animations.FadeIn.rawValue,
            "FadeOut":animations.FadeOut.rawValue
            ])
    }
    
    class func contentJSONTransformer() -> NSValueTransformer {
        
        let forwardBlock: MTLValueTransformerBlock! = {
            (jsonDic: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, aerror: NSErrorPointer) -> AnyObject! in

            let something: AnyObject! = MTLJSONAdapter.modelOfClass(ContentModel.self, fromJSONDictionary: jsonDic as! [NSObject : AnyObject], error: aerror)
            return something
        }
        
        let reverseBlock: MTLValueTransformerBlock! = {
            (contentModel: AnyObject!, succes: UnsafeMutablePointer<ObjCBool>, error: NSErrorPointer) -> AnyObject! in
            let something: AnyObject! = MTLJSONAdapter.JSONDictionaryFromModel(contentModel as! ContentModel, error: error)
            return something
        }
        
        return MTLValueTransformer(usingForwardBlock: forwardBlock, reverseBlock: reverseBlock)
    }
}

class ContentModel: Model  {
    
    enum types: String {
        case Text = "Text", Image = "Image", None = "None"
    }
    
    var type = "None"
    var value = ""
    
    class func classForParsingJSONDictionary(JSONDictionary: [NSObject : AnyObject]!) -> AnyClass! {
        
        if let type = JSONDictionary["type"] as? NSString {
            
            switch type {
            case types.Text.rawValue:
                
                return TextContentModel.self
                
            case types.Image.rawValue:
                
                return ImageContentModel.self
            default:
                
                return NoneContentModel.self
                
            }
        } else {
            return NoneContentModel.self
        }
    }

}

class NoneContentModel: ContentModel {
    
}

class ImageContentModel: ContentModel {
    var imageName = ""
}

class TextContentModel: ContentModel {
    var text = ""
}


