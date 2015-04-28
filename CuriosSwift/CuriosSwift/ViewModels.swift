//
//  ViewModels.swift
//  CuriosSwift
//
//  Created by Emiaostein on 4/28/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class Dynamic<T> {
    
    typealias Listener = T -> Void
    var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}

class BaseViewModel: NSObject {
    
}

class ContainerViewModel: BaseViewModel {
    
    let model: ContainerModel
    let x: Dynamic<CGFloat>
    let y: Dynamic<CGFloat>
    let width: Dynamic<CGFloat>
    let height: Dynamic<CGFloat>
    let rotation: Dynamic<CGFloat>
    let alpha: Dynamic<CGFloat>
    
    init(model: ContainerModel) {
        
        self.model = model
        x = Dynamic(model.x)
        y = Dynamic(model.y)
        width = Dynamic(model.width)
        height = Dynamic(model.height)
        rotation = Dynamic(model.rotation)
        alpha = Dynamic(model.alpha)
    }
    
}


