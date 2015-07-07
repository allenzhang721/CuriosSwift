//
//  IPage.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IPageProtocol: NSObjectProtocol {
    
    func pageDidSelected(page: IPage, selectedContainer: IContainer, position: CGPoint, size: CGSize, rotation: CGFloat, ratio: CGFloat, inTargetView: UIView)
    func pageDidDeSelected(page: IPage, deSelectedContainers: [IContainer])
    func pageDidDoubleSelected(page: IPage, doubleSelectedContainer: IContainer)
    func shouldMultiSelection() -> Bool
    func didEndEdit(page: IPage)
}

protocol IPage: NSObjectProtocol {
    
    func setDelegate(aDelegate: IPageProtocol)
    func cancelDelegate()
    
    func setNeedUpload(needUpload: Bool)
    func saveInfo()
    func uploadInfo(userID: String, publishID: String)
    func addContainer(aContainerModel: ContainerModel)
    func removeContainer(aContainerModel: ContainerModel)
    func exchangeContainerFromIndex(fromIndex: Int, toIndex: Int)
    
    func respondToLocation(location: CGPoint, onTargetView targetView: UIView, sender: UIGestureRecognizer?) -> Bool
    
//    var Containers: [IContainer]{get set}
    
//    func configWithPageModel(aPageModel: PageModel)
}
