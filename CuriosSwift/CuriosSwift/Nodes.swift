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
    var containerViewModel: ContainerViewModel! {
        didSet {
            containerViewModel.width.bindAndFire {
                [weak self] in
                self!.bounds.size.width = $0
                self!.containerViewModel.model.width = $0 / self!.aspectRatio
            }
            containerViewModel.height.bindAndFire {
                [weak self] in
                self!.bounds.size.height = $0
                self!.containerViewModel.model.height = $0 / self!.aspectRatio
            }
            containerViewModel.x.bindAndFire {
                [weak self] in
                println("node.x = \($0)")
                self!.position.x = $0 + self!.frame.size.width / 2.0
                self!.containerViewModel.model.x = $0 / self!.aspectRatio
            }
            containerViewModel.y.bindAndFire {
                [weak self] in
                self!.position.y = $0 + self!.frame.size.height / 2.0
                self!.containerViewModel.model.y = $0 / self!.aspectRatio
            }
            
            containerViewModel.rotation.bindAndFire {
                [weak self] in
                self!.transform = CATransform3DMakeRotation($0, 0, 0, 1)
            }
            
            containerViewModel.lIsFirstResponder.bindAndFire {
                [weak self] in
                switch self!.containerViewModel.model.component.type {
                case .None:
                    return
                case .Image:
                    return
                case .Text:
                    if let textCompNode = self!.componentNode as? TextNode {
                        textCompNode.userInteractionEnabled = $0
                        if $0 {
                            textCompNode.becomeFirstResponder()
                        } else {
                            textCompNode.resignFirstResponder()
                        }
                    }
                    
                default:
                    println("componnetModel")
                }
            }
        }
    }
    
    init(aContainerViewModel: ContainerViewModel, aspectR: CGFloat) {
        
        super.init()
        aspectRatio = aspectR
        setupComponentNode(aContainerViewModel.model.component)
        setupBy(aContainerViewModel)
        
    }
    
    func setupBy(aContainerViewModel: ContainerViewModel) {
        containerViewModel = aContainerViewModel
    }
    
    func setupComponentNode(aComponentModel: ComponentModel) {
        switch aComponentModel.type {
        case .None:
            self.componentNode = ComponentNode(aComponentModel: aComponentModel)
        case .Image:
            self.componentNode = ImageNode(aComponentModel: aComponentModel)
        case .Text:
            self.componentNode = ImageNode(aComponentModel: aComponentModel)
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
        delegate = self
    }
}

extension TextNode {
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode!) {
        contentText = editableTextNode.attributedText.string
    }
}

