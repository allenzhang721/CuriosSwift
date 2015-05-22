//
//  IPage.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IPageProtocol: NSObjectProtocol {
    
    func pageDidSelected(page: IPage, selectedContainer: IContainer, position: CGPoint, size: CGSize, rotation: CGFloat, inTargetView: UIView)
    func pageDidDeSelected(page: IPage, deSelectedContainers: [IContainer])
    func shouldMultiSelection() -> Bool
    func didEndEdit(page: IPage)
}

protocol IPage {
    
    func setDelegate(aDelegate: IPageProtocol)
    func cancelDelegate()
    
    func saveInfo()
    func addContainer(aContainerModel: ContainerModel)
    func removeContainer(aContainerModel: ContainerModel)
    
    func respondToLocation(location: CGPoint, onTargetView targetView: UIView, sender: UIGestureRecognizer?) -> Bool
    
//    var Containers: [IContainer]{get set}
    
//    func configWithPageModel(aPageModel: PageModel)
}
