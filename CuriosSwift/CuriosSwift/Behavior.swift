//
//  Behavior.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

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