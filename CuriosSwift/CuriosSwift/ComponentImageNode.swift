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
//        backgroundColor = UIColor.blueColor()
        let aImagePath = componentModel.imagePath
        
        let aImage = UIImage(contentsOfFile: aImagePath)
//        self.view.contentMode = .ScaleToFill
        image = aImage
        clipsToBounds = true
    }
    
    func resizeScale(scale: CGFloat) {
        
    }
    
    func getImageID() -> String {
        
        let aImagePath = componentModel.imagePath
        println("getaImagePath = \(aImagePath)")
        let imageID = aImagePath.lastPathComponent.stringByDeletingPathExtension
        return imageID
    }
    
    func updateImage() {
        
        let aImagePath = componentModel.imagePath
        println("updateImagePath = \(aImagePath)")
        let aImage = UIImage(contentsOfFile: aImagePath)
        //        self.view.contentMode = .ScaleToFill
        image = aImage
    }
    
    func getNeedUpload() -> Bool {
        
        return componentModel.needUpload
    }
    
    func setNeedUpload(needUpload: Bool) {
        componentModel.needUpload = true
    }
    
    // MARK: - IComponent
    func iBecomeFirstResponder(){}
    func iResignFirstResponder(){}
    func iIsFirstResponder() -> Bool {return false}
}
