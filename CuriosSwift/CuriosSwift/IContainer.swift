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
    
    func responderToLocation(location: CGPoint, onTargetView targetVew: UIView) -> Bool
    func becomeFirstResponder()
    func resignFirstResponder()
    func isFirstResponder() -> Bool
    
    func setTransation(translation: CGPoint)
    func setResize(size: CGSize, center: CGPoint)
    func setRotation(angle: CGFloat)
//    var component: IComponent{get set}
}