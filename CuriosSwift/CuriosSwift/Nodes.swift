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
    var listener: ContainerModel! {
        didSet {
            listener.lWidth.bindAndFire {
                [weak self] in
                self!.bounds.size.width = $0 * self!.aspectRatio
            }
            listener.lHeight.bindAndFire {
                [weak self] in
                self!.bounds.size.height = $0  * self!.aspectRatio
            }
            listener.lX.bindAndFire {
                [weak self] in
                self!.frame.origin.x = $0 * self!.aspectRatio
            }
            listener.lY.bindAndFire {
                [weak self] in
                self!.frame.origin.y = $0 * self!.aspectRatio
            }
            
            listener.lRotation.bindAndFire {
                [weak self] in
                self!.transform = CATransform3DMakeRotation($0, 0, 0, 1)
            }
        }
    }
    
    init(aListener: ContainerModel, aspectR: CGFloat) {
        
        super.init()
        aspectRatio = aspectR
        setupBy(aListener)
        setupComponentNode()
    }
    
    func setupBy(aListener: ContainerModel) {
        listener = aListener
    }
    
    func setupComponentNode() {
        switch listener.component.type {
        case .None:
            self.componentNode = ComponentNode(aComponentModel: listener.component)
        case .Image:
            self.componentNode = ImageNode(aComponentModel: listener.component)
        case .Text:
            self.componentNode = ImageNode(aComponentModel: listener.component)
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
        self.ImagePath = componentModel.attributes["ImagePath"] as! String
        super.init()
        self.backgroundColor = UIColor.redColor()
        let imagePath = NSTemporaryDirectory().stringByAppendingString(ImagePath)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
//            println(imagePath)
        })
        self.image = UIImage(contentsOfFile: imagePath)
    }
}

class TextNode: ASEditableTextNode,ComponentNodeAttribute {
    var componentModel: ComponentModel
    var contentText: String {
        didSet {
            componentModel.attributes["contentText"] = contentText
        }
    }
    
    init!(aComponentModel: ComponentModel) {
        self.componentModel = aComponentModel
        self.contentText = componentModel.attributes["contentText"] as! String
        super.init()
    }
}

