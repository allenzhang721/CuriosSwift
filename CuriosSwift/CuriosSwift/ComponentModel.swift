//
//  ComponentModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

protocol ComponentModelDelegate: NSObjectProtocol {
  
  func componentModelDidUpdate(model: ComponentModel)
}

class ComponentModel: Model, IFile  {
  
    var iD: String = ""
  
    @objc enum Type: Int {
        case None, Text, Image
    }
    
    weak var delegate: IFile?
    weak var editDelegate: ComponentModelDelegate?
    var type: Type = .None
    var attributes: [String : AnyObject] = [:]
  
    var needUpload = false
    
    func createComponent() -> IComponent {
        
        switch type {
        case .Text:
            return ComponentTextNode(aComponentModel: self as! TextContentModel)
        case .Image:
            
            return ComponentImageNode(aComponentModel: self as! ImageContentModel)
        default:
            return ComponentNoneNode(aComponentModel: self)
        }
    }
  
  func getResourseData(handler: (NSData?, String?) -> ()) {
  }
  
  func getResourseDataKey() -> String {
    return ""
  }
    
    func removed() {
        
    }
    
    func uploadInfo(userID: String, publishID: String, pageID: String) {
        if needUpload {
            needUpload = false
        } else {
            return
        }
    }
    
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

extension ComponentModel {
    
    func fileGetSuperPath(file: IFile) -> String {
      return ""
    }
}

class NoneContentModel: ComponentModel {
}



