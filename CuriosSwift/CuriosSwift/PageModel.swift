//
//  PageModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class PageModel: Model, IFile {
    
    weak var delegate: IFile?
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
    
    required init!(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
        super.init(dictionary: dictionaryValue, error: error)
        
        for container in containers {
            container.component.delegate = self
        }
    }
    
    override init!() {
        super.init()
        
    }
    
    func addContainer(aContainer: ContainerModel) {
        
        println("addContainer = \(aContainer)")
        containers.append(aContainer)
        aContainer.component.delegate = self
    }
    
    func removeContainer(aContainer: ContainerModel) {
        
        var index = 0
        for container in containers {
            if container.isEqual(aContainer) {
                containers.removeAtIndex(index)
                break
            }
            index++
        }
    }
    
    func saveInfo() {
        
        let path = fileGetSuperPath(self)
        let JsonPath = path.stringByAppendingPathComponent(Id + ".json")
        let pagejson = MTLJSONAdapter.JSONDictionaryFromModel(self, error: nil)
        let data = NSJSONSerialization.dataWithJSONObject(pagejson, options: NSJSONWritingOptions(0), error: nil)
        data?.writeToFile(JsonPath, atomically: true)
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

extension PageModel {
    
    func fileGetSuperPath(file: IFile) -> String {
        if let superPath = delegate?.fileGetSuperPath(self) {
            let selfPath = superPath.stringByAppendingPathComponent("Pages/\(Id)")
            return selfPath
        } else {
            assert(false, "you can not get the super path")
            return ""
        }
    }
}