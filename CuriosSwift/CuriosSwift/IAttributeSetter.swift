//
//  IAttributeSetter.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/16/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IAttributeSetter {
    
    func setTarget(target: IContainer)
    func getTarget() -> IContainer?
}