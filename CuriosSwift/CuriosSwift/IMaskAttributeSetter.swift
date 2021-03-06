//
//  IMaskAttributeSetter.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IMaskAttributeSetter: IAttributeSetter {
    
  static func createMask(postion: CGPoint, size: CGSize, rotation: CGFloat) -> IMaskAttributeSetter
    
    func remove()
}