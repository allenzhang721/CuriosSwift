//
//  ContainerMaskView.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/5/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import UIKit

protocol TargetAction {
    func performAction()
}

struct TargetActionWrapper<T: AnyObject>: TargetAction {
    
    weak var target: T?
    let action: (T) -> () -> ()
    
    func performAction() {
        if let t = target {
            action(t)()
        }
    }
}

enum ControlEvent {
    case TransitionChaged
}

class Control {
    
    
    var actions = [ControlEvent: TargetAction]()
    func setTarget<T: AnyObject>(target: T, action: (T) -> () -> (), aControlEvent: ControlEvent) {
        actions[aControlEvent] = TargetActionWrapper(target: target, action: action)
    }
    
    func removeTargetForControlEvent(controlEvent: ControlEvent) {
        actions[controlEvent] = nil
    }
    
    func performActionForControlEvent(controlEvent: ControlEvent) {
        actions[controlEvent]?.performAction()
    }
}


class ContainerMaskView: UIView, IMaskAttributeSetter {
    
//    let viewModel: ContainerViewModel
    var container: IContainer?
    
    init(postion: CGPoint, size: CGSize, rotation: CGFloat) {
        
        super.init(frame: CGRectZero)
        self.center = postion
        self.bounds.size = size
        self.transform = CGAffineTransformMakeRotation(rotation)
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        self.layer.borderColor = UIColor.redColor().CGColor
        self.layer.borderWidth = 1
        let pan = UIPanGestureRecognizer(target: self, action: "panAction:")
        self.addGestureRecognizer(pan)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
//        
//        if viewModel.lIsFirstResponder.value == true {
//            if viewModel.model.component.type == .Text {
//                
//                let ignoreRect = CGRectInset(self.bounds, 10, 10)
//                if CGRectContainsPoint(ignoreRect, point) {
//                    return false
//                } else {
//                    return true
//                }
//            }
//        }
//        
//        
//        return true
//    }
    
    func panAction(sender: UIPanGestureRecognizer) {
        
        let transition = sender.translationInView(self.superview!)
        
        if let aContainer = container {
            aContainer.setTransation(transition)
        }
        self.center.x += transition.x
        self.center.y += transition.y
        
        sender.setTranslation(CGPointZero, inView: self.superview)
    }
}

// MARK: - IMaskAttributeSetter 
extension ContainerMaskView {
    
    static func createMask(postion: CGPoint, size: CGSize, rotation: CGFloat) -> IMaskAttributeSetter {
        
        return ContainerMaskView(postion: postion, size: size, rotation: rotation)
    }
    
    func setTarget(target: IContainer) {
        
        container = target
    }
    func getTarget() -> IContainer? {
        return container
    }
    
    func remove() {
        removeFromSuperview()
    }
}
