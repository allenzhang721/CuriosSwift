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
      
      case "Animation":
      return EditToolAnimationPannel(aContainerModel: containerModel)
      
      case "Level":
      return EditToolLevelPannel(aContainerModel: containerModel)
      
    case "TextFont":
      return EditToolTextFontPannel(aContainerModel: containerModel)
      
      case "TextAlignment":
      return EditToolTextAlignmentPannel(aContainerModel: containerModel)
      
      case "TextColor":
      return EditToolTextColorPannel(aContainerModel: containerModel)
      
    default:
      return EditToolSettingPannel(aContainerModel: containerModel)
    }
  }
  
}