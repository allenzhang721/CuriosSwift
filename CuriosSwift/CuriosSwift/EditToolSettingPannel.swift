//
//  EditToolSettingPannel.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class EditToolSettingPannel: UIView {
  
  weak var delegate: EditToolSettingPannelDelegate?
  unowned var containerModel: ContainerModel
  
  init(aContainerModel: ContainerModel) {
    containerModel = aContainerModel
    super.init(frame: CGRectZero)
    
  }
  
  func begain() {
    
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}