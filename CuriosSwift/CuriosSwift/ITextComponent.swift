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
    func settFontsName(name: String) -> CGSize
    func setTextContent(text: String) -> CGSize
    func setTextColor(colorDic: [String: CGFloat])
    func getAttributeText() -> NSAttributedString
    
    //    var componentModel: ComponentModel{get set}
}