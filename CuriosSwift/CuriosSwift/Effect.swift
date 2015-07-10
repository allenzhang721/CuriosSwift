//
//  EffectModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

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