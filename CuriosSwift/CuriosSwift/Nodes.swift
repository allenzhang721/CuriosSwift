//
//  Nodes.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/1/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ContainerNode: ASDisplayNode {
    
    var aspectRatio: CGFloat = 1.0
    var componentNode:ASDisplayNode!
    var containerModel: ContainerModel! {
        didSet {
            containerModel.lWidth.bindAndFire {
                [weak self] in
                self!.bounds.size.width = $0 * self!.aspectRatio
            }
            containerModel.lHeight.bindAndFire {
                [weak self] in
                self!.bounds.size.height = $0  * self!.aspectRatio
            }
            containerModel.lX.bindAndFire {
                [weak self] in
                self!.position.x = ($0 + self!.frame.size.width / 2.0) * self!.aspectRatio
            }
            containerModel.lY.bindAndFire {
                [weak self] in
                self!.position.y = ($0 + self!.frame.size.height / 2.0) * self!.aspectRatio
            }
            
            containerModel.lRotation.bindAndFire {
                [weak self] in
                self!.transform = CATransform3DMakeRotation($0, 0, 0, 1)
            }
        }
    }
    
    init(aContainerModel: ContainerModel, aspectR: CGFloat) {
        
        super.init()
        aspectRatio = aspectR
        setupBy(aContainerModel)
        setupComponentNode()
    }
    
    func setupBy(aContainerModel: ContainerModel) {
        containerModel = aContainerModel
    }
    
    func setupComponentNode() {
        switch containerModel.component.type {
        case .None:
            self.componentNode = ComponentNode(aComponentModel: containerModel.component)
        case .Image:
            self.componentNode = ImageNode(aComponentModel: containerModel.component)
        case .Text:
            self.componentNode = ImageNode(aComponentModel: containerModel.component)
        default:
            println("componnetModel")
        }
        self.addSubnode(componentNode)
    }
    
    override func layout() {
        println(self.bounds)
        componentNode.frame = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)
    }
}

protocol ComponentNodeAttribute {
    
    var componentModel: ComponentModel {get set}
}

class ComponentNode: ASDisplayNode,ComponentNodeAttribute {

    var componentModel: ComponentModel
    
    init!(aComponentModel: ComponentModel) {
        self.componentModel = aComponentModel
        super.init()
    }
}

class ImageNode: ASImageNode,ComponentNodeAttribute {
    
    var componentModel: ComponentModel
    var ImagePath: String = "" {
        didSet {
            componentModel.attributes["ImagePath"] = ImagePath // pageID/images/imageID
            
            let imagePath = NSTemporaryDirectory().stringByAppendingString(ImagePath)
            self.image = UIImage(contentsOfFile: imagePath)
        }
    }
    
    init!(aComponentModel: ComponentModel) {
        self.componentModel = aComponentModel
//        self.contentMode = .ScaleToFill
        self.ImagePath = componentModel.attributes["ImagePath"] as! String
        super.init()
        self.backgroundColor = UIColor.redColor()
        let imagePath = NSTemporaryDirectory().stringByAppendingString(ImagePath)
        self.image = UIImage(contentsOfFile: imagePath)
        
        self.clipsToBounds = true //
    }
}

class TextNode: ASEditableTextNode,ComponentNodeAttribute,ASEditableTextNodeDelegate {
    var componentModel: ComponentModel {
        didSet {
            componentModel.lIsFirstResponder.bindAndFire {
                [unowned self] in
                self.userInteractionEnabled = $0
                if $0 {
                    self.becomeFirstResponder()
                } else {
                    self.resignFirstResponder()
                }
            }
        }
    }
    var contentText: String {
        didSet {
            componentModel.attributes["contentText"] = contentText
        }
    }
    
    init!(aComponentModel: ComponentModel) {
        self.componentModel = aComponentModel
        self.contentText = componentModel.attributes["contentText"] as! String
        super.init()
        delegate = self
    }
}

extension TextNode {
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode!) {
        contentText = editableTextNode.attributedText.string
    }
}

