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



//protocol containerListener {
//    var lX: Dynamic<CGFloat> {get}
//    var lY: Dynamic<CGFloat> {get}
//    var lWidth: Dynamic<CGFloat> {get}
//    var lHeight: Dynamic<CGFloat> {get}
//    var lRotation: Dynamic<CGFloat> {get}
//}





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


