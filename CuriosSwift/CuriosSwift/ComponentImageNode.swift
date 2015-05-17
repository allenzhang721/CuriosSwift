//
//  ComponentImageNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ComponentImageNode: ASImageNode, IImageComponent {
   
    var componentModel: ComponentModel
    var imagePath: String = "" {
        didSet {
            componentModel.attributes["ImagePath"] = imagePath
            let aImagePath = NSTemporaryDirectory().stringByAppendingString(imagePath)
            self.image = UIImage(contentsOfFile: imagePath)
        }
    }
    
    required init(aComponentModel: ComponentModel) {
        self.componentModel = aComponentModel
        self.imagePath = aComponentModel.attributes["ImagePath"]?.copy() as! String
        super.init()
        backgroundColor = UIColor.darkGrayColor()
        let aImagePath = NSTemporaryDirectory().stringByAppendingString(imagePath)
        self.image = UIImage(contentsOfFile: aImagePath)
        self.clipsToBounds = true //
    }
    
    // MARK: - IComponent
    func iBecomeFirstResponder(){}
    func iResignFirstResponder(){}
    func iIsFirstResponder() -> Bool {return false}
}
