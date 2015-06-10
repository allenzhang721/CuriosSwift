//
//  IComponent.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IComponent: NSObjectProtocol {
    
    func iBecomeFirstResponder()
    func iResignFirstResponder()
    func iIsFirstResponder() -> Bool
    
//    var componentModel: ComponentModel{get set}
}

