//
//  IContainer.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IContainer: NSObjectProtocol {
    
    var containerSize: CGSize{get}
    var containerPostion: CGPoint{get}
    var containerRotation: CGFloat{get}
    var component: IComponent!{get}
    var animationName: String{get}
    var lockedListener: Dynamic<Bool>{get}
    weak var page: IPage?{get set}
    
    func responderToLocation(location: CGPoint, onTargetView targetVew: UIView) -> Bool
    func abecomeFirstResponder()
    func aresignFirstResponder()
    func aisFirstResponder() -> Bool
    
    func setTransation(translation: CGPoint)
//    func setResize(size: CGSize, center: CGPoint)
    func getSnapshotImageAfterScreenUpdate(afterScreenUpdate: Bool) -> UIImage!
    func removed()
    
    func setAnimationWithName(name: String)
    func sendForwoard() -> Bool
    func sendBack() -> Bool
    func lockLayer() -> Bool
}