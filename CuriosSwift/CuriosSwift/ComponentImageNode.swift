//
//  ComponentImageNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ComponentImageNode: ASImageNode, IImageComponent {
   
    var componentModel: ImageContentModel
    
    required init(aComponentModel: ImageContentModel) {
        self.componentModel = aComponentModel
        super.init()
        backgroundColor = UIColor.blueColor()
        let aImagePath = componentModel.imagePath
        
        let aImage = UIImage(contentsOfFile: aImagePath)
//        self.view.contentMode = .ScaleToFill
        image = aImage
        clipsToBounds = true
    }
    
    func resizeScale(scale: CGFloat) {
        
    }
    
    // MARK: - IComponent
    func iBecomeFirstResponder(){}
    func iResignFirstResponder(){}
    func iIsFirstResponder() -> Bool {return false}
}
