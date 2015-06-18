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
    
    enum ControlStyle {
        case Rotaion, Resize, Transition
    }
    
    private weak var delegate: IMaskAttributeSetterProtocol?
    
    var controlStyle: ControlStyle = .Transition
    var angle: CGFloat = 0.0
    
    var resizePannel: UIImageView!
    var rotationPannel: UIImageView!
    var deletePannel: UIImageView!
    
    var container: IContainer?
    
    var willDeletedTargetContainer = false
    
    var currentCenter = CGPointZero
    
    init(postion: CGPoint, size: CGSize, rotation: CGFloat) {
        angle = rotation
        super.init(frame: CGRectZero)
        self.center = postion
        currentCenter = postion
        self.bounds.size = size
        self.transform = CGAffineTransformMakeRotation(rotation)
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
        setupPannel()
        setupGestures()
        
        CUAnimationFactory.shareInstance.animationStateListener.bindAndFire ("MaskView"){[unowned self] finished -> Void in
        
            if finished {
                self.hidden = false
            } else {
                self.hidden = true
            }
        }
    }
    
    deinit {
        if let aContainer = container {
            aContainer.lockedListener.removeActionWithID("MaskView")
        }
        
        CUAnimationFactory.shareInstance.animationStateListener.removeActionWithID("MaskView")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        CuriosKit.drawControlPannel(frame: rect)
        resizePannel.center = CGPointMake(bounds.width, bounds.height)
        rotationPannel.center = CGPointMake(bounds.width, 0)
        deletePannel.center = CGPointMake(0, bounds.height)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPannel() {
        
        let resizePannelImage = UIImage(named: "Editor_ResizePannel")
        resizePannel = UIImageView(image: resizePannelImage)
        resizePannel.bounds.size = CGSizeMake(40, 40)
        resizePannel.center = CGPointMake(bounds.width, bounds.height)
        addSubview(resizePannel)
        
        let rotationPannelImage = UIImage(named: "Editor_RotationPannel")
        rotationPannel = UIImageView(image: rotationPannelImage)
        rotationPannel.bounds.size = CGSizeMake(40, 40)
        rotationPannel.center = CGPointMake(bounds.width, 0)
        addSubview(rotationPannel)
        
        let deletePannelImage = UIImage(named: "Editor_DeletePannel")
        deletePannel = UIImageView(image: deletePannelImage)
        deletePannel.bounds.size = CGSizeMake(40, 40)
        deletePannel.center = CGPointMake(0, bounds.height)
        addSubview(deletePannel)
    }
    
    func setupGestures() {

        let pan = UIPanGestureRecognizer(target: self, action: "panAction:")
        let rot = UIRotationGestureRecognizer(target: self, action: "rotaionAction:")
        let pin = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
        let tap = UITapGestureRecognizer(target: self, action: "tapAction:")
        addGestureRecognizer(pan)
        addGestureRecognizer(rot)
        addGestureRecognizer(pin)
        addGestureRecognizer(tap)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        
        let rec = retangle(bounds.size, CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0))
        
        if let aContainer = container where aContainer.lockedListener.value == true {
            return rec(point)
        } else {
            let resizePannel = circle(20.0, CGPointMake(bounds.size.width, bounds.size.height))
            let rotationPannel = circle(20.0, CGPointMake(bounds.size.width, 0))
            let deletePannel = circle(20.0, CGPointMake(0, bounds.height))
            return union(deletePannel, union(rotationPannel, (union(rec, resizePannel))))(point)
        }
    }
    
    
    
//    func panAction(sender: UIPanGestureRecognizer) {
//        
//        let transition = sender.translationInView(self.superview!)
//        
//        if let aContainer = container {
//            aContainer.setTransation(transition)
//        }
//        self.center.x += transition.x
//        self.center.y += transition.y
//        
//        sender.setTranslation(CGPointZero, inView: self.superview)
//    }
    // MARK: - Gestures
    
    func tapAction(sender: UITapGestureRecognizer) {
        
        if let aContainer = container where aContainer.lockedListener.value == true {
            return
        }
        
        let point = sender.locationInView(self)
        let deleteRegion = circle(20.0, CGPointMake(0, bounds.height))
        
        if deleteRegion(point) {
            
            if let aDelegate = delegate {
                willDeletedTargetContainer = true
                aDelegate.maskAttributeWillDeleted(self)
            }
        }
    }
    
    func rotaionAction(sender: UIRotationGestureRecognizer) {
        
        if let aContainer = container where aContainer.lockedListener.value == true {
            
            return
        }
        
        let rotation = sender.rotation
        
        switch sender.state {
            
        case .Began, .Changed:
            transform = CGAffineTransformMakeRotation(angle + rotation)
            if let aContainer = container {
                aContainer.setRotation(angle + rotation)
            }
        case .Cancelled, .Ended:
            
            let newAngle = angle + rotation
            
            angle = newAngle <= 360 ? newAngle : newAngle % 360.0
            
        default:
            return
        }
        
    }
    
    var beginSize: CGSize = CGSizeZero
    
    func pinchAction(sender: UIPinchGestureRecognizer) {
        
        if let aContainer = container where aContainer.lockedListener.value == true {
            
            return
        }
        
        
        switch sender.state {
            
        case .Began:
            beginSize = bounds.size
            
        case .Changed:
            let scale = ceil((sender.scale - 1.0) * 100) / 100.0
            let widthDel = beginSize.width * scale
            let heightDel = beginSize.height * scale
            bounds.size.width = beginSize.width + widthDel
            bounds.size.height = beginSize.height + heightDel
            
            if let aContainer = container {
                aContainer.setResize(bounds.size, center: CGPointZero)
            }
            
        case .Ended, .Changed:
            return
            
        default:
            return
        }
        
        setNeedsDisplay()
    }
    
    var begainAngle: CGFloat = 0.0
    
    func panAction(sender: UIPanGestureRecognizer) {
        
        if let aContainer = container where aContainer.lockedListener.value == true {
            
            return
        }
        
        let rec = retangle(bounds.size, CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0))
        let rotationRegion = circle(22.0, CGPointMake(bounds.size.width, 0))
        let resizeRegion = circle(22.0, CGPointMake(bounds.size.width, bounds.size.height))
        
        switch sender.state {
            
        case .Began:
            
            let position = sender.locationInView(self)
            
            switch position {
            case let point where rotationRegion(point):
                let location = sender.locationInView(superview!)
                begainAngle = atan2(location.y - center.y, location.x - center.x)
                
                controlStyle = .Rotaion
            case let point where resizeRegion(point):
                controlStyle = .Resize
            default:
                controlStyle = .Transition
            }
            
        case .Changed:
            
            switch controlStyle {
                
            case .Transition:
                let transition = sender.translationInView(superview!)
                
                if let aContainer = container {
                    aContainer.setTransation(transition)
                }
                center.x += transition.x
                center.y += transition.y
                
                currentCenter = center
                
            case .Resize:
                let sizeDel = sender.translationInView(self)
                let centerDel = sender.translationInView(superview!)
                let width = bounds.size.width + sizeDel.x
                let height = bounds.size.height + sizeDel.y
                
                let realWidth = width <= 50 ? 50 : width
                let realHeight = height <= 50 ? 50 : height
                
                let delCenX = width <= 50 ? 0 : centerDel.x / 2.0
                let delCenY = height <= 50 ? 0 : centerDel.y / 2.0
                
                let centerX = center.x + delCenX
                let centerY = center.y + delCenY
                
                bounds.size.width = realWidth
                bounds.size.height = realHeight
                center.x = centerX
                center.y = centerY
                
                currentCenter = center
                
                if let aContainer = container {
                    aContainer.setResize(CGSize(width: realWidth, height: realHeight), center: CGPoint(x: delCenX, y: delCenY))
                }
                
            case .Rotaion:
                
                let location = sender.locationInView(superview!)
                let transition  = sender.translationInView(self)
                let ang = atan2(location.y - center.y, location.x - center.x)
                let angDel = ang - begainAngle
                transform = CGAffineTransformMakeRotation(angle + angDel)
                
                if let aContainer = container {
                    aContainer.setRotation(angle + angDel)
                }
                
            default:
                return
            }
            
            sender.setTranslation(CGPointZero, inView: self)
            sender.setTranslation(CGPointZero, inView: superview!)
            
        case .Cancelled, .Ended:
            
            switch controlStyle {
                
            case .Rotaion:
                let location = sender.locationInView(superview!)
                let ang = atan2(location.y - center.y, location.x - center.x)
                let angDel = ang - begainAngle
                angle += angDel
                
            default:
                return
            }

        default:
            return
        }
        
        setNeedsDisplay()
    }
}

// MARK: - IMaskAttributeSetter 
extension ContainerMaskView {
    
    static func createMask(postion: CGPoint, size: CGSize, rotation: CGFloat) -> IMaskAttributeSetter {
        
        return ContainerMaskView(postion: postion, size: size, rotation: rotation)
    }
    
    func setDelegate(aDelegate: IMaskAttributeSetterProtocol) {
        delegate = aDelegate
    }
    func cancelDelegate() {
        delegate = nil
    }
    
    func setTarget(target: IContainer) {
        container = target
        
        container?.lockedListener.bindAndFire ("MaskView"){ [unowned self] locked -> Void in
            
            self.resizePannel.hidden = locked
            self.rotationPannel.hidden = locked
        }
        
        setNeedsDisplay()
    }
    func getTarget() -> IContainer? {
        return container
    }
    
    func remove() {
        
        if willDeletedTargetContainer {
            if let aContainer = container {
                aContainer.removed()
            }
        }
        
        
        cancelDelegate()
        removeFromSuperview()
    }
}
