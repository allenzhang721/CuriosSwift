//
//  EditToolBarDelegate.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol EditToolBarDelegate: NSObjectProtocol {
  
  // begain \ change \ end
  func editToolBar(toolBar: EditToolBar, activedWithContainerModel containerModel: ContainerModel)
  func editToolBar(toolBar: EditToolBar, didChangedToContainerModel containerModel: ContainerModel)
  func editToolBarDidDeactived(toolBar: EditToolBar)
  
  // Default - Setting / AddText / AddImage / Preview
  func editToolBarDidSelectedSetting(toolBar: EditToolBar)
  func editToolBarDidSelectedPreview(toolBar: EditToolBar)
  func editToolBarDidSelectedAddImage(toolBar: EditToolBar)
  func editToolBarDidSelectedAddText(toolBar: EditToolBar)
  func editToolBarDidSelectedCancel(toolBar: EditToolBar)
 
  
}

protocol EditToolBarSettingDelegate: NSObjectProtocol {

  // container - LayerIndex / Animation
  func editToolBar(toolBar: EditToolBar, didSelectedLevel containerModel: ContainerModel)
  func editToolBar(toolBar: EditToolBar, didSelectedAnimation containerModel: ContainerModel)
  
  // text - FontName / Color / Alignment
  func editToolBar(toolBar: EditToolBar, didSelectedTextFont containerModel: ContainerModel)
  func editToolBar(toolBar: EditToolBar, didSelectedTextColor containerModel: ContainerModel)
  func editToolBar(toolBar: EditToolBar, didSelectedTextAlignment containerModel: ContainerModel)
  
  // image - mask
  func editToolBar(toolBar: EditToolBar, didSelectedAddMask containerModel: ContainerModel)
  
}

