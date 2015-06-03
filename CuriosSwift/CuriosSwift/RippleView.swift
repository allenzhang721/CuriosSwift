//
//  RippleView.swift
//
//  Code generated using QuartzCode 1.30.3 on 6/3/15.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class RippleView: UIView {
	
	var layers : Dictionary<String, AnyObject> = [:]
	var completionBlocks : Dictionary<CAAnimation, (Bool) -> Void> = [:]
	var updateLayerValueForCompletedAnimation : Bool = true
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupProperties()
		setupLayers()
	}
	
	required init(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		setupProperties()
		setupLayers()
	}
	
	override var frame: CGRect{
		didSet{
			setupLayerFrames()
		}
	}
	
	override var bounds: CGRect{
		didSet{
			setupLayerFrames()
		}
	}
	
	func setupProperties(){
		
	}
	
	func setupLayers(){
		self.backgroundColor = UIColor(red:1, green: 1, blue:1, alpha:0)
		
		var ripple : CALayer = CALayer()
		self.layer.addSublayer(ripple)
		layers["ripple"] = ripple
		var one : CAShapeLayer = CAShapeLayer()
		ripple.addSublayer(one)
		layers["one"] = one
		var one2 : CAShapeLayer = CAShapeLayer()
		ripple.addSublayer(one2)
		layers["one2"] = one2
		var one3 : CAShapeLayer = CAShapeLayer()
		ripple.addSublayer(one3)
		layers["one3"] = one3
		
		setupLayerFrames()
        addUntitled1Animation()
		resetLayerPropertiesForLayerIdentifiers(nil)
	}
	
	func resetLayerPropertiesForLayerIdentifiers(layerIds: [String]!){
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		if layerIds == nil || contains(layerIds, "one"){
			var one = layers["one"] as! CAShapeLayer
			one.fillColor   = nil
			one.strokeColor = UIColor(red:0.502, green: 0, blue:1, alpha:1).CGColor
		}
		if layerIds == nil || contains(layerIds, "one2"){
			var one2 = layers["one2"] as! CAShapeLayer
			one2.fillColor   = nil
			one2.strokeColor = UIColor(red:0.502, green: 0, blue:1, alpha:1).CGColor
		}
		if layerIds == nil || contains(layerIds, "one3"){
			var one3 = layers["one3"] as! CAShapeLayer
			one3.fillColor   = nil
			one3.strokeColor = UIColor(red:0.502, green: 0, blue:1, alpha:1).CGColor
		}
		
		CATransaction.commit()
	}
	
	func setupLayerFrames(){
		if let ripple : CALayer = layers["ripple"] as? CALayer{
			ripple.frame = CGRectMake(0, 0,  ripple.superlayer.bounds.width,  ripple.superlayer.bounds.height)
		}
		
		if let one : CAShapeLayer = layers["one"] as? CAShapeLayer{
			one.frame = CGRectMake(0, 0,  one.superlayer.bounds.width,  one.superlayer.bounds.height)
			one.path  = onePathWithBounds(one.bounds).CGPath;
		}
		
		if let one2 : CAShapeLayer = layers["one2"] as? CAShapeLayer{
			one2.frame = CGRectMake(0, 0,  one2.superlayer.bounds.width,  one2.superlayer.bounds.height)
			one2.path  = one2PathWithBounds(one2.bounds).CGPath;
		}
		
		if let one3 : CAShapeLayer = layers["one3"] as? CAShapeLayer{
			one3.frame = CGRectMake(0, 0,  one3.superlayer.bounds.width,  one3.superlayer.bounds.height)
			one3.path  = one3PathWithBounds(one3.bounds).CGPath;
		}
		
	}
	
	func addUntitled1Animation(){
		var fillMode : String = kCAFillModeForwards
		
		////An infinity animation
		
		////One animation
		
		let one = layers["one"] as! CAShapeLayer
		
		var oneTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
		oneTransformAnim.values         = [NSValue(CATransform3D: CATransform3DIdentity), 
			 NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(2.25, 2.25, 1)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(3.38, 3.38, 1))]
		oneTransformAnim.keyTimes       = [0, 0.333, 0.667, 1]
		oneTransformAnim.duration       = 3.3
		oneTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
		oneTransformAnim.repeatCount    = Float.infinity
		
		var oneOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
		oneOpacityAnim.values         = [1, 0]
		oneOpacityAnim.keyTimes       = [0, 1]
		oneOpacityAnim.duration       = 3.3
		oneOpacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
		oneOpacityAnim.repeatCount    = Float.infinity
		
		var oneUntitled1Anim : CAAnimationGroup = QCMethod.groupAnimations([oneTransformAnim, oneOpacityAnim], fillMode:fillMode)
		layers["one"]?.addAnimation(oneUntitled1Anim, forKey:"oneUntitled1Anim")
		
		////One2 animation
		
		let one2 = layers["one2"] as! CAShapeLayer
		
		var one2TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
		one2TransformAnim.values         = [NSValue(CATransform3D: CATransform3DIdentity), 
			 NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(2.25, 2.25, 1)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(3.38, 3.38, 1))]
		one2TransformAnim.keyTimes       = [0, 0.333, 0.667, 1]
		one2TransformAnim.duration       = 3.3
		one2TransformAnim.beginTime      = 1.1
		one2TransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
		one2TransformAnim.repeatCount    = Float.infinity
		
		var one2OpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
		one2OpacityAnim.values         = [1, 0]
		one2OpacityAnim.keyTimes       = [0, 1]
		one2OpacityAnim.duration       = 3.3
		one2OpacityAnim.beginTime      = 1.1
		one2OpacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
		one2OpacityAnim.repeatCount    = Float.infinity
		
		var one2Untitled1Anim : CAAnimationGroup = QCMethod.groupAnimations([one2TransformAnim, one2OpacityAnim], fillMode:fillMode)
		layers["one2"]?.addAnimation(one2Untitled1Anim, forKey:"one2Untitled1Anim")
		
		////One3 animation
		
		let one3 = layers["one3"] as! CAShapeLayer
		
		var one3TransformAnim            = CAKeyframeAnimation(keyPath:"transform")
		one3TransformAnim.values         = [NSValue(CATransform3D: CATransform3DIdentity), 
			 NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(2.25, 2.25, 1)), 
			 NSValue(CATransform3D: CATransform3DMakeScale(3.38, 3.38, 1))]
		one3TransformAnim.keyTimes       = [0, 0.333, 0.667, 1]
		one3TransformAnim.duration       = 3.3
		one3TransformAnim.beginTime      = 2.2
		one3TransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
		one3TransformAnim.repeatCount    = Float.infinity
		
		var one3OpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
		one3OpacityAnim.values         = [1, 0]
		one3OpacityAnim.keyTimes       = [0, 1]
		one3OpacityAnim.duration       = 3.3
		one3OpacityAnim.beginTime      = 2.2
		one3OpacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
		one3OpacityAnim.repeatCount    = Float.infinity
		
		var one3Untitled1Anim : CAAnimationGroup = QCMethod.groupAnimations([one3TransformAnim, one3OpacityAnim], fillMode:fillMode)
		layers["one3"]?.addAnimation(one3Untitled1Anim, forKey:"one3Untitled1Anim")
	}
	
	override func animationDidStop(anim: CAAnimation, finished flag: Bool){
		if let completionBlock = completionBlocks[anim]{
			completionBlocks.removeValueForKey(anim)
			if (flag && updateLayerValueForCompletedAnimation) || anim.valueForKey("needEndAnim") as! Bool{
				updateLayerValuesForAnimationId(anim.valueForKey("animId") as! String)
				removeAnimationsForAnimationId(anim.valueForKey("animId") as! String)
			}
			completionBlock(flag)
		}
	}
	
	func updateLayerValuesForAnimationId(identifier: String){
		if identifier == "Untitled1"{
			QCMethod.updateValueFromPresentationLayerForAnimation((layers["one"] as! CALayer).animationForKey("oneUntitled1Anim"), theLayer:(layers["one"] as! CALayer))
			QCMethod.updateValueFromPresentationLayerForAnimation((layers["one2"] as! CALayer).animationForKey("one2Untitled1Anim"), theLayer:(layers["one2"] as! CALayer))
			QCMethod.updateValueFromPresentationLayerForAnimation((layers["one3"] as! CALayer).animationForKey("one3Untitled1Anim"), theLayer:(layers["one3"] as! CALayer))
		}
	}
	
	func removeAnimationsForAnimationId(identifier: String){
		if identifier == "Untitled1"{
			(layers["one"] as! CALayer).removeAnimationForKey("oneUntitled1Anim")
			(layers["one2"] as! CALayer).removeAnimationForKey("one2Untitled1Anim")
			(layers["one3"] as! CALayer).removeAnimationForKey("one3Untitled1Anim")
		}
	}
	
	//MARK: - Bezier Path
	
	func onePathWithBounds(bound: CGRect) -> UIBezierPath{
		var onePath = UIBezierPath(ovalInRect: bound)
		return onePath;
	}
	
	func one2PathWithBounds(bound: CGRect) -> UIBezierPath{
		var one2Path = UIBezierPath(ovalInRect: bound)
		return one2Path;
	}
	
	func one3PathWithBounds(bound: CGRect) -> UIBezierPath{
		var one3Path = UIBezierPath(ovalInRect: bound)
		return one3Path;
	}
	
	
}
