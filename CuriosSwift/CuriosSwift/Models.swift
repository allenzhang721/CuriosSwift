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
   
}

class BookModel: Model {
    var pages: [PageModel] = []
}

class PageModel: Model {
    var size = CGSizeZero
    var items: [ItemModel] = []
}


class ItemModel: Model {

    enum animations {
        case None, FadeIn, FadeOut
    }
    
    var center = CGPointZero
    var size = NSValue(CGSize: CGSizeZero)
    var rotation = NSNumber(float: 0)
    var editable = NSNumber(bool: true)
    var animation :animations = .None
    var content = NoneContentModel()
    
    class override func dictionaryWithValuesForKeys(keys: [AnyObject]) -> [NSObject : AnyObject] {
        return ["size" : "size",
                "center" : "center",
                "rotation" : "rotation",
                "content" : "content"]
    }
    
    class func sizeJSONTransformer() -> NSValueTransformer {
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


