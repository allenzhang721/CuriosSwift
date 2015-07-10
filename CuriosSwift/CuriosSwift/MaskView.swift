//
//  MaskView.swift
//  
//
//  Created by Emiaostein on 7/10/15.
//
//

import UIKit

class MaskView: UIView {
  
  enum ControlStyle {
    case Rotaion, Resize, Transition, None
  }
  
  var containerMomdel: ContainerModel!
  
  var settingPannel: UIImageView!
  var resizePannel: UIImageView!
  var rotationPannel: UIImageView!
  var deletePannel: UIImageView!
  
  var begainAngle: CGFloat = 0.0
  var controlStyle: ControlStyle = .None
  
  static func maskWithCenter(center: CGPoint, size: CGSize, angle: CGFloat, targetContainerModel aContainerModel: ContainerModel) -> MaskView {
    
    return MaskView(aCenter: center, size: size, aAngle: angle, aContainerModel: aContainerModel)
  }
  
  init(aCenter: CGPoint, size: CGSize, aAngle: CGFloat, aContainerModel: ContainerModel) {
    super.init(frame: CGRectZero)
    containerMomdel = aContainerModel
    center = aCenter
    bounds.size = size
    transform = CGAffineTransformMakeRotation(aAngle)
    backgroundColor = UIColor.clearColor()
    
    bindingContainerModel()
    addGestures()
    addPannels()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
      super.drawRect(rect)
      CuriosKit.drawControlPannel(frame: rect)
      resizePannel.center = CGPointMake(bounds.width, bounds.height)
      rotationPannel.center = CGPointMake(bounds.width, 0)
      deletePannel.center = CGPointMake(0, bounds.height)
      settingPannel.center = CGPointMake(0, 0)
    }
  
  deinit {
    unBindingContainerModel()
  }
}

// MARK: - Private Method Init
extension MaskView {
  
  func bindingContainerModel() {
    
    containerMomdel.postionChangeListener.bind("Mask_View") {[unowned self] postion -> Void in
      
      self.center.x += postion.x
      self.center.y += postion.y
    }
    
    containerMomdel.sizeChangeListener.bind("Mask_View") { size -> Void in
      
    }
    
    containerMomdel.rotationListener.bind("Mask_View") { [unowned self] angle -> Void in
      
      self.transform = CGAffineTransformMakeRotation(angle)
    }
  }
  
  func unBindingContainerModel() {
    
    containerMomdel.postionChangeListener.removeActionWithID("Mask_View")
    containerMomdel.sizeChangeListener.removeActionWithID("Mask_View")
    containerMomdel.rotationListener.removeActionWithID("Mask_View")
  }
  
  func addGestures() {
    
    let pan = UIPanGestureRecognizer(target: self, action: "panAction:")
    let rot = UIRotationGestureRecognizer(target: self, action: "rotationAction:")
    let pin = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
    
    addGestureRecognizer(pan)
    addGestureRecognizer(rot)
    addGestureRecognizer(pin)
  }
  
  func addPannels() {
    
    let settingPannelImage = UIImage(named: "Editor_SettingPannel")
    settingPannel = UIImageView(image: settingPannelImage)
    settingPannel.bounds.size = CGSizeMake(40, 40)
    settingPannel.center = CGPointMake(0, 0)
    addSubview(settingPannel)
    
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
}

// MARK: - Private Method gestures
extension MaskView {
  
  
  func panAction(sender: UIPanGestureRecognizer) {
    
    let rec = retangle(bounds.size, CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0))
    let resizeRegion = retangle(CGSizeMake(40, 40), CGPointMake(bounds.size.width, bounds.size.height))
    let rotationRegion = retangle(CGSizeMake(40, 40), CGPointMake(bounds.size.width, 0))
    
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
      case let point where rec(point):
        controlStyle = .Transition
      default:
        controlStyle = .None
      }
      
    case .Changed:
      
      switch controlStyle {
        
      case .Transition:
        let transition = sender.translationInView(superview!)
        containerMomdel.setPostionChange(transition)
        
      case .Resize:
        println("")
        
      case .Rotaion:
        let location = sender.locationInView(superview!)
        let transition  = sender.translationInView(self)
        let ang = atan2(location.y - center.y, location.x - center.x)
        let angDel = ang - begainAngle
        containerMomdel.setAngleChange(angDel)
        begainAngle = ang
        
      default:
        return
      }
      
      sender.setTranslation(CGPointZero, inView: self)
      sender.setTranslation(CGPointZero, inView: superview!)
      
    case .Cancelled, .Ended:
      println("")
      
    default:
      return
    }
    
  }
  
  func rotationAction(sender: UIRotationGestureRecognizer) {
    
  }
  
  func pinchAction(sender: UIPinchGestureRecognizer) {
    
  }
}


