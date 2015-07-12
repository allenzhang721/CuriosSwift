//
//  ComponentImageNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ComponentImageNode: ASImageNode, IImageComponent {
  
  var componentModel: ImageContentModel
  
  required init(aComponentModel: ImageContentModel) {
    self.componentModel = aComponentModel
    super.init()
    
    componentModel.generateImage {[weak self] (image) -> () in
      
      self?.image = image
    }
    
    componentModel.updateImageHandler({[weak self] (image) -> () in
      self?.image = image
      })
    cropEnabled = false
    clipsToBounds = true
  }
  
  func resizeScale(scale: CGFloat) {
    
  }
  
  func getImageID() -> String {
    
    return ""
  }
  
  func updateImage() {
    
  }
  
  func getNeedUpload() -> Bool {
    
    return componentModel.needUpload
  }
  
  func setNeedUpload(needUpload: Bool) {
    componentModel.needUpload = true
  }
  
  // MARK: - IComponent
  func iBecomeFirstResponder(){}
  func iResignFirstResponder(){}
  func iIsFirstResponder() -> Bool {return false}
}
