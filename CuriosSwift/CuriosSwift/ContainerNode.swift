//
//  ContainerNode.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

class ContainerNode: ASDisplayNode, IContainer {
    
    private let containerModel: ContainerModel
    private var component: IComponent!
    private var componentNode: ASDisplayNode!
    private let aspectRatio: CGFloat
    
    init(postion: CGPoint, size: CGSize, rotation:CGFloat, aspectRatio theAspectRatio: CGFloat,aContainerModel: ContainerModel) {
        self.aspectRatio = theAspectRatio
        self.containerModel = aContainerModel
        super.init()
        position = postion
        bounds.size = size
        transform = CATransform3DMakeRotation(rotation, 0, 0, rotation)
        component = containerModel.component.createComponent()
        
        if let aCom = component as? ASDisplayNode {
            addSubnode(aCom)
        }
    }
}

// MARK: - private method
extension ContainerNode {
    
        override func layout() {
            for subNode in subnodes as! [ASDisplayNode] {
                subNode.frame = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height)
            }
        }
    
}
