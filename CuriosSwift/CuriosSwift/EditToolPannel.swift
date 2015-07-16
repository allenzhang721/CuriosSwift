//
//  EditToolPannel.swift
//  
//
//  Created by Emiaostein on 7/16/15.
//
//

import UIKit

class EditToolPannel: UIView, EditToolBarSettingDelegate {

  var settingPannel: EditToolSettingPannel!

}

//MARK: - EditToolBarSettingDelgate 
extension EditToolPannel {
  
  // container - LayerIndex / Animation
  func editToolBar(toolBar: EditToolBar, didSelectedLevel containerModel: ContainerModel) {
    println("Level")
  }
  
  func editToolBar(toolBar: EditToolBar, didSelectedAnimation containerModel: ContainerModel) {
    println("Animation")
  }
  
  // text - FontName / Color / Alignment
  func editToolBar(toolBar: EditToolBar, didSelectedTextFont containerModel: ContainerModel) {
    println("TextFont")
  }
  func editToolBar(toolBar: EditToolBar, didSelectedTextColor containerModel: ContainerModel) {
    println("TextColor")
  }
  func editToolBar(toolBar: EditToolBar, didSelectedTextAlignment containerModel: ContainerModel) {
    println("TextAlignment")
  }
  
  // image - none
}
