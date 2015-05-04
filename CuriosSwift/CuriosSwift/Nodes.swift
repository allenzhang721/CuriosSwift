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
    var viewModel: ContainerViewModel! {
        didSet {
            viewModel.width.bindAndFire {
                [unowned self] in
                self.bounds.size.width = $0
            }
            viewModel.height.bindAndFire {
                [unowned self] in
                self.bounds.size.height = $0
            }
            viewModel.x.bindAndFire {
                [unowned self] in
                self.frame.origin.x = $0
                self.viewModel.model.x = $0 / self.aspectRatio
            }
            viewModel.y.bindAndFire {
                [unowned self] in
                self.frame.origin.y = $0
                self.viewModel.model.y = $0 / self.aspectRatio
            }
            
            viewModel.rotation.bindAndFire {
                [unowned self] in
                self.transform = CATransform3DMakeRotation($0, 0, 0, 1)
            }
        }
    }
    
    init(viewModel: ContainerViewModel, aspectR: CGFloat) {
        
        super.init()
        aspectRatio = aspectR
        setupBy(viewModel)
        setupComponentNode()
    }
    
    func setupBy(viewModel: ContainerViewModel) {
        self.viewModel = viewModel
    }
    
    func setupComponentNode() {
        switch viewModel.model.component.type {
        case .None:
            self.componentNode = ComponentNode(aComponentModel: viewModel.model.component)
        case .Image:
            self.componentNode = ImageNode(aComponentModel: viewModel.model.component)
        case .Text:
            self.componentNode = ImageNode(aComponentModel: viewModel.model.component)
        default:
            println("componnetModel")
        }
        self.addSubnode(componentNode)
    }
    
    override func layout() {
        
        componentNode.frame = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.width)
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
            componentModel.attributes["ImagePath"] = ImagePath
            
            let bundlePath = NSBundle.mainBundle().bundlePath.stringByAppendingString("/" + ImagePath)
            self.image = UIImage(contentsOfFile: bundlePath)
        }
    }
    
    init!(aComponentModel: ComponentModel) {
        self.componentModel = aComponentModel
        self.ImagePath = componentModel.attributes["ImagePath"] as! String
        super.init()
        self.backgroundColor = UIColor.redColor()
        let docuPath: String = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String).stringByAppendingString("/res")
        let bundlePath = docuPath.stringByAppendingString("/Pages/page_1" + ImagePath)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        })
        
        
        self.image = UIImage(contentsOfFile: bundlePath)
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

