//
//  ComponentModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class ComponentModel: Model, IFile  {
    
    @objc enum Type: Int {
        case None, Text, Image
    }
    
    weak var delegate: IFile?
    var type: Type = .None
    var attributes: [String : AnyObject] = [:]
    var needUpload = false
    
    // listener
    //    let lIsFirstResponder: Dynamic<Bool>
    
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
    
    //    override init!() {
    //        lIsFirstResponder = Dynamic(false)
    //        super.init()
    //
    //    }
    //
    //    required init!(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
    //        //        fatalError("init(dictionary:error:) has not been implemented")
    //        lIsFirstResponder = Dynamic(false)
    //        super.init(dictionary: dictionaryValue, error: error)
    //    }
    
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

class ImageContentModel: ComponentModel, IFile {
    
    var imagePath: String {
        
        get {
            let selfPath = attributes["ImagePath"] as! String
            if let string = delegate?.fileGetSuperPath(self).stringByAppendingPathComponent(selfPath) {
                return string
            } else {
                return ""
            }
        }
        
        set {
            needUpload = true
            attributes["ImagePath"] = newValue
        }
    }
    
    override func uploadInfo(userID: String, publishID: String, pageID: String) {
//        super.uploadInfo(userID, publishID: publishID, pageID: pageID)
        
        if needUpload {
            needUpload = false
        }else {
            return
        }
        
        let selfPath = attributes["ImagePath"] as! String
        let key = userID.stringByAppendingPathComponent(publishID).stringByAppendingPathComponent("res").stringByAppendingPathComponent("Pages").stringByAppendingPathComponent(pageID).stringByAppendingPathComponent(selfPath)
        let value = imagePath
        
        FileUplodRequest.uploadFileWithKeyFile([key:value])
        
        println("imageModel:key:\(key)")
    }
    
    override func removed() {
        
        let fileManager = NSFileManager()
        fileManager.removeItemAtPath(imagePath, error: nil)
        needUpload = false
        super.removed()
    }
}

class TextContentModel: ComponentModel {
    
    override func uploadInfo(userID: String, publishID: String, pageID: String) {
        //        super.uploadInfo(userID, publishID: publishID, pageID: pageID)
        
        if needUpload {
            needUpload = false
        }else {
            return
        }
        
        let selfPath = attributes["ImagePath"] as! String
        let key = userID.stringByAppendingPathComponent(publishID).stringByAppendingPathComponent("res").stringByAppendingPathComponent("Pages").stringByAppendingPathComponent(pageID).stringByAppendingPathComponent(selfPath)
        let valuePath = userID.stringByAppendingPathComponent(publishID).stringByAppendingPathComponent("Pages").stringByAppendingPathComponent(pageID).stringByAppendingPathComponent(selfPath)
        let value = temporaryDirectory(valuePath).path!
        
        FileUplodRequest.uploadFileWithKeyFile([key:value])
        
        println("TextimageModel:key:\(key)")
    }
}