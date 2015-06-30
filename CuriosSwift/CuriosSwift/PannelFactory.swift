//
//  PannelFactory.swift
//  CuriosSwift
//
//  Created by Emiaostein on 6/12/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class PannelFactory {
    
    static let shareInstance = PannelFactory()
    
    func createPannelWithType(type: PannelType) -> Pannel {
        
        switch type {
            
        case .Effect:
            return EffectPannel()
            
        case .Font:
            return FontPannel()
            
        case .FontAttribute:
            return FontAttributePannel()
            
        case .FontSize:
            
            return FontsizePannel()
            
        case .Typography:
            
            return TypographyPannel()
            
        case .Animation:
            
            return AnimationPannel()
        }
        
    }
}