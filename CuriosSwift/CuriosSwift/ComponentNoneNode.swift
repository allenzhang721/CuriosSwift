//
//  ComponentNoneNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ComponentNoneNode: ASDisplayNode, IComponent {
   
    var componentModel: ComponentModel
    
    required init(aComponentModel: ComponentModel) {
        self.componentModel = aComponentModel
        super.init()
    }
    
    func resizeScale(scale: CGFloat) {
        
    }
    
    // MARK: - IComponent 
    func iBecomeFirstResponder(){}
    func iResignFirstResponder(){}
    func iIsFirstResponder() -> Bool {return false}
}
