//
//  EditToolPannel.swift
//  
//
//  Created by Emiaostein on 7/16/15.
//
//

import UIKit
import SnapKit

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
    
    if let apannel = settingPannel {
      apannel.removeConstraints(apannel.constraints())
      apannel.removeFromSuperview()
    }
    
    println(bounds)
    
    settingPannel = EditToolSettingPannelFactory.createSettingPannelwithKey("TextColor", containerModel: containerModel)
    settingPannel.bounds = bounds
    
    addSubview(settingPannel)
    
  }
  func editToolBar(toolBar: EditToolBar, didSelectedTextAlignment containerModel: ContainerModel) {
    println("TextAlignment")
  }
  
  // image - none
}


//MARK: - Constraints
extension EditToolPannel {
  
  override func updateConstraints() {
    
    if let aPannel = settingPannel {
      aPannel.snp_makeConstraints({ (make) -> Void in
        make.edges.equalTo(self)
      })
    }
    super.updateConstraints()
  }
}
