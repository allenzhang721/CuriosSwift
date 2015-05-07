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

class PageViewModel: BaseViewModel {
    let model: PageModel
    let aspectRatio: CGFloat
    let size: CGSize
    var containers: [ContainerViewModel] = [] // 缩放后的大小
    
    init(aModel: PageModel) {
        
        model = aModel
        aspectRatio = PageViewModel.getAspectRatio(aModel)
        size = CGSize(width: model.width, height: model.height)
        super.init()
        containers = getContainerViewModel(aModel, aRatio: aspectRatio)
    }
    
    private func getContainerViewModel(aPageModel: PageModel, aRatio: CGFloat) -> [ContainerViewModel] {
        
        var array: [ContainerViewModel] = []
        let containerModels = aPageModel.containers
        for containerM in containerModels {
            let containtVM = ContainerViewModel(model: containerM, aspectRatio: aRatio)
            array.append(containtVM)
        }
        return array
    }
    
   class func getAspectRatio(cellVM: PageModel) -> CGFloat {
        let normalWidth = LayoutSpec.layoutConstants.normalLayout.itemSize.width
        let normalHeight = LayoutSpec.layoutConstants.normalLayout.itemSize.height
        return min(normalWidth / cellVM.width, normalHeight / cellVM.height)
    }
}

protocol ContainerAttributes {
    var lIsFirstResponder: Dynamic<Bool> {get}
}

class ContainerViewModel: BaseViewModel, ContainerAttributes {
    
    let model: ContainerModel
    let x: Dynamic<CGFloat>
    let y: Dynamic<CGFloat>
    let width: Dynamic<CGFloat>
    let height: Dynamic<CGFloat>
    let rotation: Dynamic<CGFloat>
    let alpha: Dynamic<CGFloat>
    let lIsFirstResponder: Dynamic<Bool>
    init(model: ContainerModel, aspectRatio: CGFloat) {
        
        self.model = model
        x = Dynamic(model.x * aspectRatio)
        y = Dynamic(model.y  * aspectRatio)
        width = Dynamic(model.width  * aspectRatio)
        height = Dynamic(model.height * aspectRatio)
        rotation = Dynamic(model.rotation)
        alpha = Dynamic(model.alpha)
        lIsFirstResponder = Dynamic(false)

    }
    
}

class MaskViewModel: BaseViewModel {
    
    let model: ContainerViewModel
    let x: Dynamic<CGFloat>
    let y: Dynamic<CGFloat>
    let width: Dynamic<CGFloat>
    let height: Dynamic<CGFloat>
    let rotation: Dynamic<CGFloat>
    
    init(model: ContainerViewModel) {
        
        self.model = model
        x = Dynamic(model.x.value)
        y = Dynamic(model.y.value)
        width = Dynamic(model.width.value)
        height = Dynamic(model.height.value)
        rotation = Dynamic(model.rotation.value)

    }
    
}


