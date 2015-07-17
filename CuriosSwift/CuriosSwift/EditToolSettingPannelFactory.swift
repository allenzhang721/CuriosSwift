//
//  EditToolSettingPannelFactory.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class EditToolSettingPannelFactory {
  
  class func createSettingPannelwithKey(key: String, containerModel: ContainerModel) -> EditToolSettingPannel {
    
    switch key {
      
    default:
      return EditToolTextColorPannel(aContainerModel: containerModel)
    }
  }
  
}