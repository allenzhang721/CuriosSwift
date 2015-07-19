//
//  IPage.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IPageProtocol: NSObjectProtocol {
  
  
  func pageDidSelected(page: PageModel, selectedContainer container: ContainerModel, onView: UIView ,onViewCenter: CGPoint, size: CGSize, angle: CGFloat)
  func pageDidDeSelected(page: PageModel, deselectedContainer container: ContainerModel)
  func pageDidDoubleSelected(page: PageModel, doubleSelectedContainer container: ContainerModel)
  func pageDidEndEdit(page: PageModel)
}

protocol IPage: NSObjectProtocol {
  
  func begainResponseToTap(onScreenPoint: CGPoint, tapCount: Int)
    
    func setDelegate(aDelegate: IPageProtocol)
    func cancelDelegate()
    
    func saveInfo()
    func exchangeContainerFromIndex(fromIndex: Int, toIndex: Int)
}
