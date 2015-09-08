//
//  MaskView.swift
//  
//
//  Created by Emiaostein on 7/10/15.
//
//

import UIKit

protocol MaskViewDelegate: NSObjectProtocol {
  
  func maskViewDidSelectedDeleteItem(mask: MaskView, deletedContainerModel containerModel: ContainerModel)
  func maskViewDidSelectedEditItem(mask: MaskView, EditedContainerModel containerModel: ContainerModel)
  
}

class MaskView: UIView, UIGestureRecognizerDelegate {
  
  enum ControlStyle {
    case Rotaion, Resize, Transition, None
  }
  
  var containerMomdel: ContainerModel!
  var tap: UITapGestureRecognizer!
  weak var delegate: MaskViewDelegate?
  
  var settingPannel: UIImageView!
  var resizePannel: UIImageView!
  var rotationPannel: UIImageView!
  var deletePannel: UIImageView!
  
  var begainAngle: CGFloat = 0.0
  var beginSize: CGSize = CGSizeZero
  var panBeginSize: CGSize = CGSizeZero
  var pinchbegainFontSize: CGFloat = 0
  var begainScale: CGFloat = 1.0
  var begainFontSize: CGFloat = 1.0
  var begainFontScale: CGFloat = 1.0
  var ratio: CGFloat = 0.0 // bounds width / height
  var controlStyle: ControlStyle = .None
  var binding = false
  
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
    
//    aContainerModel.selectedListener.bind("Mask_View") {[weak self] selected -> Void in
//      
//      if selected {
//        self?.bindingContainerModel()
//      } else {
//        self?.unBindingContainerModel()
//      }
//      
//    }
    
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
      
      if containerMomdel.locked {
        resizePannel.hidden = true
        rotationPannel.hidden = true
        deletePannel.hidden = true
        settingPannel.hidden = true
      } else {
        
        resizePannel.hidden = false
        rotationPannel.hidden = false
        deletePannel.hidden = false
        settingPannel.hidden = false
      }
      
      resizePannel.center = CGPointMake(bounds.width, bounds.height)
      rotationPannel.center = CGPointMake(bounds.width, 0)
      deletePannel.center = CGPointMake(0, bounds.height)
      settingPannel.center = CGPointMake(0, 0)
    }
  
  deinit {
    unBindingContainerModel()
  }
}

// MARK: - Gesture Delegate
extension MaskView {
  
  override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    
    if containerMomdel.locked {
      
      let gestures = gestureRecognizers as! [UIGestureRecognizer] as NSArray
      
      return !gestures.containsObject(gestureRecognizer)
    }
    
    if gestureRecognizer == tap {
      
      let deleteRegion = retangle(CGSizeMake(20, 20), CGPoint(x: 0, y: bounds.height))
      let editRegion = retangle(CGSize(width: 40, height: 40), CGPointZero)
      
      let location = gestureRecognizer.locationInView(self)
      switch location {
      case let point where deleteRegion(point):
        return true
        
      case let point where editRegion(point):
        return true
        
      default:
        return false
      }
    } else {
      return true
    }

    
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    
    if otherGestureRecognizer is UITapGestureRecognizer {
      return false
    }
  return true
  }
}

// MARK: - Private Method Init
extension MaskView {
  
  func bindingContainerModel() {
    
    if binding {
      return
    }
    
    binding = true
    
    containerMomdel.lockChangedListener.bind ("Mask_View"){[unowned self] locked -> Void in
      
      self.setNeedsDisplay()
    }
    
    
    CUAnimationFactory.shareInstance.animationStateListener.bind ("Mask_View"){[unowned self] finished -> Void in
      
      if finished {
        self.hidden = false
      } else {
        self.hidden = true
      }
    }
    containerMomdel.updateSizeListener.bind("Mask_View") {[unowned self] size -> Void in
      
      self.bounds.size = size
      self.setNeedsDisplay()
    }
    
    containerMomdel.centerChangeListener.bind("Mask_View") {[unowned self] postion -> Void in
      
      self.center.x += postion.x
      self.center.y += postion.y
    }
    
    containerMomdel.sizeChangeListener.bind("Mask_View") {[unowned self] size -> Void in
      
      self.bounds.size.width += size.width
      self.bounds.size.height += size.height
    }
    
    containerMomdel.rotationListener.bind("Mask_View") { [unowned self] angle -> Void in
      
      self.transform = CGAffineTransformMakeRotation(angle)
    }
  }
  
  func unBindingContainerModel() {

    if !binding {
      return
    }
    
    binding = false
    containerMomdel.lockChangedListener.removeActionWithID("Mask_View")
    CUAnimationFactory.shareInstance.animationStateListener.removeActionWithID("Mask_View")
    containerMomdel.updateSizeListener.removeActionWithID("Mask_View")
    containerMomdel.centerChangeListener.removeActionWithID("Mask_View")
    containerMomdel.sizeChangeListener.removeActionWithID("Mask_View")
    containerMomdel.rotationListener.removeActionWithID("Mask_View")
  }
  
  func addGestures() {
    
    tap = UITapGestureRecognizer(target: self, action: "tapAction:")
    let pan = UIPanGestureRecognizer(target: self, action: "panAction:")
    let rot = UIRotationGestureRecognizer(target: self, action: "rotationAction:")
    let pin = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
    
    tap.delegate = self
    pan.delegate = self
    rot.delegate = self
    pin.delegate = self
    
    addGestureRecognizer(tap)
    addGestureRecognizer(pan)
    addGestureRecognizer(rot)
    addGestureRecognizer(pin)
  }
  
  func addPannels() {
    
    let deletePannelImage = UIImage(named: "Editor_DeletePannel")
    deletePannel = UIImageView(image: deletePannelImage)
    deletePannel.bounds.size = CGSizeMake(25, 25)
    deletePannel.center = CGPointMake(0, bounds.height)
    addSubview(deletePannel)
    
    let settingPannelImage = UIImage(named: "Editor_SettingPannel")
    settingPannel = UIImageView(image: settingPannelImage)
    settingPannel.bounds.size = CGSizeMake(25, 25)
    settingPannel.center = CGPointMake(0, 0)
    addSubview(settingPannel)
    
    let resizePannelImage = UIImage(named: "Editor_ResizePannel")
    resizePannel = UIImageView(image: resizePannelImage)
    resizePannel.bounds.size = CGSizeMake(25, 25)
    resizePannel.center = CGPointMake(bounds.width, bounds.height)
    addSubview(resizePannel)
    
    let rotationPannelImage = UIImage(named: "Editor_RotationPannel")
    rotationPannel = UIImageView(image: rotationPannelImage)
    rotationPannel.bounds.size = CGSizeMake(25, 25)
    rotationPannel.center = CGPointMake(bounds.width, 0)
    addSubview(rotationPannel)
    
    
  }
  
  override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    
    let rec = retangle(bounds.size, CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0))
    let resizePannel = retangle(CGSizeMake(40, 40), CGPointMake(bounds.size.width, bounds.size.height))
    let rotationPannel = retangle(CGSizeMake(40, 40), CGPointMake(bounds.size.width, 0))
    let deletePannel = retangle(CGSizeMake(20, 20), CGPointMake(0, bounds.height))
    let setPannel = retangle(CGSizeMake(40, 40), CGPointMake(0, 0))
    return union(setPannel ,union(deletePannel, union(rotationPannel, (union(rec, resizePannel)))))(point)
  }
}

// MARK: - Private Method gestures
extension MaskView {
  
  func tapAction(sender: UITapGestureRecognizer) {
    
    let deleteRegion = retangle(CGSizeMake(20, 20), CGPoint(x: 0, y: bounds.height))
    let editRegion = retangle(CGSize(width: 40, height: 40), CGPointZero)
    
    let location = sender.locationInView(self)
    switch location {
    case let point where editRegion(point):
      delegate?.maskViewDidSelectedEditItem(self, EditedContainerModel: containerMomdel)
      
    case let point where deleteRegion(point):
      delegate?.maskViewDidSelectedDeleteItem(self, deletedContainerModel: containerMomdel)

    default:
      return
    }
  }

  func panAction(sender: UIPanGestureRecognizer) {
    
    let rec = retangle(bounds.size, CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0))
    let resizeRegion = retangle(CGSizeMake(40, 40), CGPointMake(bounds.size.width, bounds.size.height))
    let rotationRegion = retangle(CGSizeMake(40, 40), CGPointMake(bounds.size.width, 0))
    
    switch sender.state {
    case .Began:
      
      if let compoenent = containerMomdel.component as? TextContentModel {
        let textSize = compoenent.retriveTextRectSize()
        panBeginSize = textSize
        debugPrint.p("begainTextSize = \(textSize)")
        ratio = textSize.width / textSize.height
        begainFontSize = compoenent.getFontSize()
      }
      
      containerMomdel.updateSlopes()
      
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
        containerMomdel.setCenterChange(transition)
        containerMomdel.setOriginChange(transition)
        
      case .Resize:
        
        if containerMomdel.component is ImageContentModel {
          
          let transition = sender.translationInView(self)
          let transitionCenter = sender.translationInView(superview!)
          
          var delWidth = transition.x
          var delHeight = transition.y
          
          var width = bounds.width + delWidth
          var height = bounds.height + delHeight
          
          if let apoint = containerMomdel.retriveSlopeCorrectPoint(CGPoint(x: width, y: height)) {
            
            delWidth = apoint.x - bounds.width
            delHeight = apoint.y - bounds.height
            width = apoint.x
            height = apoint.y
          }
          
          let minWidth: CGFloat = 40.0
          let minHeight: CGFloat = 40.0
          
          let widthBool = width <= minWidth
          let heightBool = height <= minHeight
          
          let widthChanged: CGFloat = widthBool ? 0 : delWidth
          let heightChanged: CGFloat = heightBool ? 0 : delHeight
          
          let finalWidth = width + widthChanged
          let finalHeight = height + heightChanged
          
          let begainPoint = CGPoint(x: width, y: height)
          let endPoint = CGPoint(x: finalWidth, y: finalHeight)
          
          let onSuperBegainPoint = self.convertPoint(begainPoint, toView: superview)
          let onSuperEndPoint = self.convertPoint(endPoint, toView: superview)
          
          let centerXChanged: CGFloat = (onSuperEndPoint.x - onSuperBegainPoint.x) / 2.0
          let centerYChanged: CGFloat = (onSuperEndPoint.y - onSuperBegainPoint.y) / 2.0
          
          containerMomdel.setSizeChange(CGSize(width: widthChanged, height: heightChanged))
          containerMomdel.setCenterChange(CGPoint(x: centerXChanged, y: centerYChanged))
          containerMomdel.setOriginChange(CGPoint(x: 0 - widthChanged / 2.0 + centerXChanged, y:0 - heightChanged / 2.0 + centerYChanged))
          
        } else if let textComponent = containerMomdel.component as? TextContentModel {
          
          let transition = sender.translationInView(self)
          let transitionx = sender.translationInView(superview!)
          
          let width = bounds.width + transition.x
          let height = bounds.height + transition.y
          
          let minWidth: CGFloat = 30.0
          let minHeight: CGFloat = 30.0
          
          let textSize = panBeginSize
          
          let targetminWidthScale = minWidth / textSize.width
          let targetminHeightScale = minHeight / textSize.height
          let targetScale = max(targetminWidthScale, targetminHeightScale)
          let targetWdith = targetScale * textSize.width
          let targetHeight = targetScale * textSize.height
          
          let widthLimited = width <= minWidth
          let heightLimited = height <= minHeight
          
          let finalWidth = widthLimited ? minWidth : width
          let finalHeight = heightLimited ? minHeight : height
          
          let finalTransitionX = widthLimited ? 0 : transition.x
          let finalTransitionY = heightLimited ? 0: transition.y

          
          let widthScale = finalWidth / textSize.width
          let heighScale = finalHeight / textSize.height
          let minScale = min(widthScale, heighScale)
          
          let r = finalWidth / finalHeight
          
          if !widthLimited && !heightLimited && !(fabs(r - ratio) < 0.1) {
            let sizeChangeHeight = ratio >= 1 ? transition.x / ratio : transition.y
            let sizeChangeWidth = ratio >= 1 ? transition.x : transition.y * ratio

            textComponent.setFontSize(begainFontSize * minScale)
            containerMomdel.setSizeChange(CGSize(width:sizeChangeWidth, height: sizeChangeHeight))
            containerMomdel.setCenterChange(CGPoint(x: sizeChangeWidth / 2.0, y: sizeChangeHeight / 2.0))
          } else {
            
            let sizeChangeWidth = (ratio < 1.0) ? 0 : (finalWidth <= targetWdith ? finalTransitionX : 0)
            let sizeChangeHeight = (ratio > 1.0) ? 0 : (finalHeight <= targetHeight ? finalTransitionY : 0)
            
            textComponent.setFontSize(begainFontSize * minScale)
            containerMomdel.setSizeChange(CGSize(width:sizeChangeWidth, height: sizeChangeHeight))
            containerMomdel.setCenterChange(CGPoint(x: sizeChangeWidth / 2.0, y: sizeChangeHeight / 2.0))
          }

//
          
          
          
//          if !heightBool && !widthBool {
//            containerMomdel.setSizeChange(CGSize(width: sizeChangeWidth, height: sizeChangeHeight))
//            containerMomdel.setCenterChange(CGPoint(x: sizeChangeWidth / 2.0, y: sizeChangeHeight / 2.0))
//            let scale = bounds.width / panBeginSize.width
//            textComponent.setFontSize(scale * begainFontSize)
//          }
          
          
         
//          containerMomdel.setOriginChange(CGPoint(x: 0 - transition.y * ratio / 2.0 + transitionx.x / 2.0, y:0 - transition.y / 2.0 + transitionx.y / 2.0))

          
        }
        
        
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
      setNeedsDisplay()
      
    case .Cancelled, .Ended:
      return
    default:
      return
    }
    
  }
  
  func rotationAction(sender: UIRotationGestureRecognizer) {
    
    let rotation = sender.rotation
    
    switch sender.state {
      
    case .Began:
      begainAngle = 0
      
      case .Changed:
      
      let angleChanged = rotation - begainAngle
      containerMomdel.setAngleChange(angleChanged)
      begainAngle = rotation
      
    case .Cancelled, .Ended:
      
      return
      
    default:
      return
    }
  }
  
  func pinchAction(sender: UIPinchGestureRecognizer) {
    
    switch sender.state {
      
    case .Began:
      beginSize = bounds.size
      begainScale = sender.scale
      
      if let compoenent = containerMomdel.component as? TextContentModel {
        pinchbegainFontSize = compoenent.getFontSize()
        begainFontScale = 1.0
      }
      
    case .Changed:
      let scale = ceil((sender.scale - begainScale) * 100) / 100.0
      begainScale = sender.scale
      let widthDel = beginSize.width * scale
      let heightDel = beginSize.height * scale
      containerMomdel.setSizeChange(CGSize(width: widthDel, height: heightDel))
      containerMomdel.setOriginChange(CGPoint(x: 0 - widthDel / 2.0, y: 0 - heightDel / 2.0))
      
      if let compoenent = containerMomdel.component as? TextContentModel {
        
        let ascale = bounds.width / beginSize.width
        compoenent.setFontSize(pinchbegainFontSize * ascale)
      }
      
      
    case .Ended, .Cancelled:
      return
      
    default:
      return
    }
    
    setNeedsDisplay()
  }
}


