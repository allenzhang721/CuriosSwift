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
    class func modelOfClass<T: MTLModel>(T.Type, fromJSONDictionary: [String: AnyObject]?) -> (T?, NSError?) {
        var error: NSError?
        let model = modelOfClass(T.self, fromJSONDictionary: fromJSONDictionary, error: &error) as? T
        return (model, error)
    }
    
    class func modelsOfClass<T: MTLModel>(T.Type, fromJSONArray: [AnyObject]!) -> ([T]?, NSError?) {
        var error: NSError?
        let models = modelsOfClass(T.self, fromJSONArray: fromJSONArray, error: &error)
        return (models as? [T], error)
    }
}

class Model: MTLModel {
    struct jsonGeometryKey {
        static let size = "size" + "."
        static let center = "center" + "."
    }
}

class BookModel: Model {
    var pages: [PageModel] = []
}

class PageModel: Model {
    var width = 0
    var height = 0
    var items: [ItemModel] = []
    
    class override func dictionaryWithValuesForKeys(keys: [AnyObject]) -> [NSObject : AnyObject] {
        return ["width" : jsonGeometryKey.size + "width",
            "height" : jsonGeometryKey.size + "height",
            "items" : "items"]
    }
}


class ItemModel: Model {
    
    @objc enum animations: Int {
        case None, FadeIn, FadeOut
    }
    
    var x = 0 // center.x
    var y = 0 // center.y
    var width = 0 // size.width
    var height = 0 // size.height
    var rotation = 0
    var editable = true
    var animation :animations = .None
    var content = NoneContentModel()
    
    class override func dictionaryWithValuesForKeys(keys: [AnyObject]) -> [NSObject : AnyObject] {
        return [
            
                "x" : jsonGeometryKey.center + "x",
                "y" : jsonGeometryKey.center + "y",
                "width" : jsonGeometryKey.size + "width",
                "height" : jsonGeometryKey.size + "height",
        ]
    }
    
    class func animaitonJSONTransformer() -> NSValueTransformer {
        
        return NSValueTransformer.mtl_valueMappingTransformerWithDictionary([
            "None":animations.None.rawValue,
            "FadeIn":animations.FadeIn.rawValue,
            "FadeOut":animations.FadeOut.rawValue
            ])
    }
}

class ContentModel: Model {

}

class NoneContentModel: ContentModel {
    
}

class ImageContentModel: ContentModel {
    var imageName = ""
}

class TextContentModel: ContentModel {
    var text = ""
}


