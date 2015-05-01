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
    }
    
    func setupBy(viewModel: ContainerViewModel) {
        self.viewModel = viewModel
    }
}

