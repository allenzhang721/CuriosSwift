//
//  PageModel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

protocol PageModelEditDelegate: NSObjectProtocol {
  
  func targetPageModelDidUpdate(model: PageModel)
  
}

protocol PageModelDelegate: NSObjectProtocol {
  
  func targetPageModel(model: PageModel, DidAddContainer container: ContainerModel)
  func targetpageModel(model: PageModel, DidRemoveContainer container: ContainerModel)
}

class PageModel: Model, IFile, ContainerModelSuperEditDelegate {
  

  
  weak var editDelegate: PageModelEditDelegate?
  weak var delegate: IFile?
  var Id = ""
  var width: CGFloat = 640.0
  var height: CGFloat = 1008.0
  var pageBackgroundColor = "255,255,255" { // red, green, blue
    didSet {
      editDelegate?.targetPageModelDidUpdate(self)
    }
    
  }
  var pageBackgroundAlpha: CGFloat = 1.0 {
    
    didSet {
      editDelegate?.targetPageModelDidUpdate(self)
    }
  }
  
  
  var pageTitle = "" {
    didSet {
      editDelegate?.targetPageModelDidUpdate(self)
    }
  }
  
  var pageDesc = "" {
    
    didSet {
      editDelegate?.targetPageModelDidUpdate(self)
    }
  }
  
  var containers: [ContainerModel] = []
  
  weak var modelDelegate: PageModelDelegate?
  
  override class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
    
    return [
      "Id"                  : "ID",
      "width"               : "PageWidth",
      "height"              : "PageHeight",
      "pageBackgroundColor" : "PageBackgroundColor",
      "pageBackgroundAlpha" : "PageBackgroundAlpha",
      "containers"          : "Containers",
      "pageTitle"           : "PageTitle",
      "pageDesc"            : "PageDesc"
    ]
  }
  
  required init!(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
    super.init(dictionary: dictionaryValue, error: error)
    
    for container in containers {
      container.component.delegate = self
      container.editDelegate = self
    }
  }
  
  override init!() {
    super.init()
  }
  
  typealias aResult = PageModel
  static func converFromData(data: NSData!) -> (aResult?, NSError?) {
    
    if let dic = Dictionary<NSObject, AnyObject>.converFromData(data).0 {
      
      if let model = MTLJSONAdapter.modelOfClass(aResult.self, fromJSONDictionary: dic, error: nil) as? PageModel {
        return (model, nil)
      } else {
        return (nil, nil)
      }
    } else {
      return (nil, nil)
    }
  }
}

//MARK: - ContainerSuperEditDelegate
extension PageModel {
  
  func containerModelDidUpdate(model: ContainerModel) {
    
    editDelegate?.targetPageModelDidUpdate(self)
  }
  
  func containerModel(model: ContainerModel, levelDidChanged sendForward: Bool) -> Bool {
    
    if containers.count <= 0 {
      return false
    }
    
    let count = containers.count
    let aContainers = containers as NSArray
    let index = aContainers.indexOfObject(model)
    
    if sendForward {
      if index == count - 1 {
        return false
      }
      editDelegate?.targetPageModelDidUpdate(self)
      exchange(&containers, index, index + 1)
      return true
      
    } else {
      if index == 0 {
        return false
      }
      editDelegate?.targetPageModelDidUpdate(self)
      exchange(&containers, index, index - 1)
      return true
    }
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
      aContainer.editDelegate = self
      containers.append(aContainer)
      editDelegate?.targetPageModelDidUpdate(self)
      modelDelegate?.targetPageModel(self, DidAddContainer: aContainer)
  }
  
  
  func removeContainerModel(aContainer: ContainerModel) {
    
    editDelegate?.targetPageModelDidUpdate(self)
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
    aContainer.editDelegate = self
    editDelegate?.targetPageModelDidUpdate(self)
    modelDelegate?.targetPageModel(self, DidAddContainer: aContainer)
  }
  
  func removeContainer(aContainer: ContainerModel) {

    editDelegate?.targetPageModelDidUpdate(self)
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
  
  func saveInfo() {
    
    //        let path = fileGetSuperPath(self)
    //        let JsonPath = path.stringByAppendingPathComponent(Id + ".json")
    //        let pagejson = MTLJSONAdapter.JSONDictionaryFromModel(self, error: nil)
    //        let data = NSJSONSerialization.dataWithJSONObject(pagejson, options: NSJSONWritingOptions(0), error: nil)
    //        data?.writeToFile(JsonPath, atomically: true)
  }
  
//  func uploadInfo(userID: String, publishID: String) {
//    
//    for container in containers {
//      if !needUpload && container.needUpload {
//        needUpload = true
//      }
//      container.needUpload = false
//      let component = container.component
//      component.uploadInfo(userID, publishID: publishID, pageID: Id)
//    }
//    
//    if needUpload {
//      needUpload = false
//    } else {
//      return
//    }
//    
//    let key = userID.stringByAppendingPathComponent(publishID).stringByAppendingPathComponent("res").stringByAppendingPathComponent("Pages").stringByAppendingPathComponent(Id + ".json")
//    let path = fileGetSuperPath(self)
//    let value = path.stringByAppendingPathComponent(Id + ".json")
//    
//    FileUplodRequest.uploadFileWithKeyFile([key:value])
//    println("PageModel:Key:\(key)")
//  }
  
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
