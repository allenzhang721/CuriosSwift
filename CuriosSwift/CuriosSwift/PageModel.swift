//
//  PageModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle


protocol PageModelDelegate: NSObjectProtocol {
  
  func targetPageModel(model: PageModel, DidAddContainer container: ContainerModel)
  func targetpageModel(model: PageModel, DidRemoveContainer container: ContainerModel)
}

class PageModel: Model, IFile {
  
  weak var delegate: IFile?
  var Id = UniqueIDString()
  var width: CGFloat = 640.0
  var height: CGFloat = 1008.0
  var containers: [ContainerModel] = []
  weak var modelDelegate: PageModelDelegate?
  var needUpload = false
  
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
}

extension PageModel {
  
  func addContainerModel(aContainer: ContainerModel,
    OnScreenSize size: CGSize) {
      
      let pixelWidth = size.width * 2.0
      let pixelheight = size.height * 2.0
      
      if pixelWidth <= width && pixelheight <= height {
        
        let finalWidth = pixelWidth
        let finalHeight = pixelheight
        let finalx = (width - finalWidth) / 2.0
        let finaly = (height - finalHeight) / 2.0

        aContainer.width = finalWidth
        aContainer.height = finalHeight
        aContainer.x = finalx
        aContainer.y = finaly
      } else {
        
        let aspectio = min(width / pixelWidth ,height / pixelheight)
        
        let finalWidth = aspectio * pixelWidth
        let finalHeight = aspectio * pixelheight
        let finalx = (width - finalWidth) / 2.0
        let finaly = (height - finalHeight) / 2.0
        aContainer.width = finalWidth
        aContainer.height = finalHeight
        aContainer.x = finalx
        aContainer.y = finaly
      }
      
      aContainer.component.delegate = self
      containers.append(aContainer)
      modelDelegate?.targetPageModel(self, DidAddContainer: aContainer)
  }
  
  
  func removeContainerModel(aContainer: ContainerModel) {
    
    modelDelegate?.targetpageModel(self, DidRemoveContainer: aContainer)
    
    var index = 0
    for container in containers {
      if container.isEqual(aContainer) {
        containers.removeAtIndex(index)
        break
      }
      index++
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  func addContainer(aContainer: ContainerModel) {
    
    containers.append(aContainer)
    aContainer.component.delegate = self
    modelDelegate?.targetPageModel(self, DidAddContainer: aContainer)
    needUpload = true
  }
  
  func removeContainer(aContainer: ContainerModel) {
    
    
    modelDelegate?.targetpageModel(self, DidRemoveContainer: aContainer)
    
    var index = 0
    for container in containers {
      if container.isEqual(aContainer) {
        containers.removeAtIndex(index)
        break
      }
      index++
    }
    needUpload = true
  }
  
  func saveInfo() {
    
    //        let path = fileGetSuperPath(self)
    //        let JsonPath = path.stringByAppendingPathComponent(Id + ".json")
    //        let pagejson = MTLJSONAdapter.JSONDictionaryFromModel(self, error: nil)
    //        let data = NSJSONSerialization.dataWithJSONObject(pagejson, options: NSJSONWritingOptions(0), error: nil)
    //        data?.writeToFile(JsonPath, atomically: true)
  }
  
  func uploadInfo(userID: String, publishID: String) {
    
    for container in containers {
      if !needUpload && container.needUpload {
        needUpload = true
      }
      container.needUpload = false
      let component = container.component
      component.uploadInfo(userID, publishID: publishID, pageID: Id)
    }
    
    if needUpload {
      needUpload = false
    } else {
      return
    }
    
    let key = userID.stringByAppendingPathComponent(publishID).stringByAppendingPathComponent("res").stringByAppendingPathComponent("Pages").stringByAppendingPathComponent(Id + ".json")
    let path = fileGetSuperPath(self)
    let value = path.stringByAppendingPathComponent(Id + ".json")
    
    FileUplodRequest.uploadFileWithKeyFile([key:value])
    println("PageModel:Key:\(key)")
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
