//
//  EditToolPannelDelegate.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol EditToolSettingProperties {
  
  weak var settingDelegate: EditToolSettingPannelDelegate?{get set}
  
}

protocol EditToolSettingPannelDelegate: NSObjectProtocol {
  
  // container - index \ lock \ animation
  func editToolPannel(pannel: EditToolPannel, didSelectedLayerSendForward containerModel: ContainerModel)
  func editToolPannel(pannel: EditToolPannel, didSelectedLayerSendBackward containerModel: ContainerModel)
  func editToolPannel(pannel: EditToolPannel, didSelectedLocked locked: Bool, containerModel: ContainerModel)
  func editToolPannel(pannel: EditToolPannel, didSelectedAnimation animationName: String, containerModel: ContainerModel)
  
  // text  - color \ fontName \ size \ alignment
  func editToolPannel(pannel: EditToolPannel, didSelectedTextFontName fontName: String, containerModel: ContainerModel)
  func editToolPannel(pannel: EditToolPannel, didSelectedTextColor color: String, containerModel: ContainerModel)
  func editToolPannel(pannel: EditToolPannel, didSelectedTextAlignment alignment: String, containerModel: ContainerModel)
  
  // image - none
}