//
//  IMaskAttributeSetter.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IMaskAttributeSetterProtocol: NSObjectProtocol {
    
    func maskAttributeWillDeleted(sender: IMaskAttributeSetter)
}

protocol IMaskAttributeSetter: IAttributeSetter {
    
//    weak var delegate: IMaskAttributeSetterProtocol?{get set}
    
    
    func setDelegate(aDelegate: IMaskAttributeSetterProtocol)
    func cancelDelegate()
    
    var currentCenter: CGPoint {get}
  static func createMask(postion: CGPoint, size: CGSize, rotation: CGFloat) -> IMaskAttributeSetter
    
    func remove()
}