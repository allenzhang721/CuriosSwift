//
//  ITextComponent.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol ITextComponent: IComponent {
    
    func setFontAligement(aligement: Int)
    func setFontSize(plus: Bool)
    func settFontsName(name: String)
    
    //    var componentModel: ComponentModel{get set}
}