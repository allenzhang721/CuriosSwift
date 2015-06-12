//
//  RippleView.swift
//
//  Code generated using QuartzCode 1.31.2 on 6/3/15.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class RippleView: UIView {
	
	var layers : Dictionary<String, AnyObject> = [:]
	var completionBlocks : Dictionary<CAAnimation, (Bool) -> Void> = [:]
	var updateLayerValueForCompletedAnimation : Bool = false
	
	
	
	//MARK: - Life Cycle
	
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
		
		var effect : CALayer = CALayer()
		self.layer.addSublayer(effect)
		layers["effect"] = effect
		var shadow : CAShapeLayer = CAShapeLayer()
		effect.addSublayer(shadow)
		layers["shadow"] = shadow
		
		var shadow2 : CAShapeLayer = CAShapeLayer()
		self.layer.addSublayer(shadow2)
		layers["shadow2"] = shadow2
		
		var line : CAShapeLayer = CAShapeLayer()
		self.layer.addSublayer(line)
		layers["line"] = line
		
		var placeHolder : CAShapeLayer = CAShapeLayer()
		self.layer.addSublayer(placeHolder)
		layers["placeHolder"] = placeHolder
		
		setupLayerFrames()
		resetLayerPropertiesForLayerIdentifiers(nil)
	}
	
	func resetLayerPropertiesForLayerIdentifiers(layerIds: [String]!){
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		if layerIds == nil || contains(layerIds, "effect"){
			var effect = layers["effect"] as! CALayer
			effect.hidden = true
		}
		if layerIds == nil || contains(layerIds, "shadow"){
			var shadow = layers["shadow"] as! CAShapeLayer
			shadow.hidden      = true
			shadow.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
			shadow.strokeColor = UIColor(red:0.329, green: 0.329, blue:0.329, alpha:1).CGColor
		}
		if layerIds == nil || contains(layerIds, "shadow2"){
			var shadow2 = layers["shadow2"] as! CAShapeLayer
			shadow2.fillColor     = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
			shadow2.strokeColor   = UIColor(red:0.329, green: 0.329, blue:0.329, alpha:1).CGColor
			shadow2.shadowColor   = UIColor(red:0, green: 0, blue:0, alpha:0.702).CGColor
			shadow2.shadowOpacity = 0.7
			shadow2.shadowOffset  = CGSizeMake(0, 0)
			shadow2.shadowRadius  = 5
		}
		if layerIds == nil || contains(layerIds, "line"){
			var line = layers["line"] as! CAShapeLayer
			line.fillColor   = nil
			line.strokeColor = UIColor.whiteColor().CGColor
		}
		if layerIds == nil || contains(layerIds, "placeHolder"){
			var placeHolder = layers["placeHolder"] as! CAShapeLayer
			placeHolder.hidden      = true
			placeHolder.fillColor   = UIColor(red:0.922, green: 0.922, blue:0.922, alpha:1).CGColor
			placeHolder.strokeColor = UIColor(red:0.329, green: 0.329, blue:0.329, alpha:0).CGColor
		}
		
		CATransaction.commit()
	}
	
	func setupLayerFrames(){
		if let effect : CALayer = layers["effect"] as? CALayer{
			effect.frame = CGRectMake(0.61111 * effect.superlayer.bounds.width, -0.61035 * effect.superlayer.bounds.height,  effect.superlayer.bounds.width,  effect.superlayer.bounds.height)
		}
		
		if let shadow : CAShapeLayer = layers["shadow"] as? CAShapeLayer{
			shadow.frame = CGRectMake(0, 0,  shadow.superlayer.bounds.width,  shadow.superlayer.bounds.height)
			shadow.path  = shadowPathWithBounds((layers["shadow"] as! CAShapeLayer).bounds).CGPath;
		}
		
		if let shadow2 : CAShapeLayer = layers["shadow2"] as? CAShapeLayer{
			shadow2.frame = CGRectMake(0, 0.00076 * shadow2.superlayer.bounds.height,  shadow2.superlayer.bounds.width,  shadow2.superlayer.bounds.height)
			shadow2.path  = shadow2PathWithBounds((layers["shadow2"] as! CAShapeLayer).bounds).CGPath;
		}
		
		if let line : CAShapeLayer = layers["line"] as? CAShapeLayer{
			line.frame = CGRectMake(0, 0,  line.superlayer.bounds.width,  line.superlayer.bounds.height)
			line.path  = linePathWithBounds((layers["line"] as! CAShapeLayer).bounds).CGPath;
		}
		
		if let placeHolder : CAShapeLayer = layers["placeHolder"] as? CAShapeLayer{
			placeHolder.frame = CGRectMake(0.61111 * placeHolder.superlayer.bounds.width, -0.61111 * placeHolder.superlayer.bounds.height,  placeHolder.superlayer.bounds.width,  placeHolder.superlayer.bounds.height)
			placeHolder.path  = placeHolderPathWithBounds((layers["placeHolder"] as! CAShapeLayer).bounds).CGPath;
		}
		
	}
	
	//MARK: - Animation Setup
	
	func addBreathAnimation(){
		var fillMode : String = kCAFillModeForwards
		
		////An infinity animation
		
		////Effect animation
		var effectShadowOpacityAnim            = CABasicAnimation(keyPath:"shadowOpacity")
		effectShadowOpacityAnim.toValue        = 1
		effectShadowOpacityAnim.duration       = 1
		effectShadowOpacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
		effectShadowOpacityAnim.repeatCount    = Float.infinity
		effectShadowOpacityAnim.autoreverses   = true
		effectShadowOpacityAnim.setValue(3, forKeyPath:"instanceDelay")
		effectShadowOpacityAnim.setValue(0, forKeyPath:"instanceOrder")
		var effectShadowOffsetAnim             = CABasicAnimation(keyPath:"shadowOffset")
		effectShadowOffsetAnim.toValue         = NSValue(CGSize: CGSizeMake(0, 0))
		effectShadowOffsetAnim.duration        = 1
		effectShadowOffsetAnim.timingFunction  = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
		effectShadowOffsetAnim.repeatCount     = Float.infinity
		effectShadowOffsetAnim.autoreverses    = true
		effectShadowOffsetAnim.setValue(3, forKeyPath:"instanceDelay")
		effectShadowOffsetAnim.setValue(0, forKeyPath:"instanceOrder")
		var effectShadowRadiusAnim             = CABasicAnimation(keyPath:"shadowRadius")
		effectShadowRadiusAnim.toValue         = 10
		effectShadowRadiusAnim.duration        = 1
		effectShadowRadiusAnim.timingFunction  = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
		effectShadowRadiusAnim.repeatCount     = Float.infinity
		effectShadowRadiusAnim.autoreverses    = true
		effectShadowRadiusAnim.setValue(3, forKeyPath:"instanceDelay")
		effectShadowRadiusAnim.setValue(0, forKeyPath:"instanceOrder")
		
		////Effect animation
		var effectOpacityAnim         = CAKeyframeAnimation(keyPath:"opacity")
		effectOpacityAnim.values      = [1, 1, 0, 0]
		effectOpacityAnim.keyTimes    = [0, 0.5, 0.502, 1]
		effectOpacityAnim.duration    = 4
		effectOpacityAnim.repeatCount = Float.infinity
		
		var effectBreathAnim : CAAnimationGroup = QCMethod.groupAnimations([effectShadowOpacityAnim, effectShadowOffsetAnim, effectShadowRadiusAnim, effectOpacityAnim], fillMode:kCAFillModeBoth, forEffectLayer:true, sublayersCount:1)
		QCMethod.addSublayersAnimation(effectBreathAnim, key:"effectBreathAnim", layer:layers["effect"] as! CALayer)
		
		////Shadow2 animation
		var shadow2OpacityAnim         = CAKeyframeAnimation(keyPath:"opacity")
		shadow2OpacityAnim.values      = [0, 1, 0, 0]
		shadow2OpacityAnim.keyTimes    = [0, 0.25, 0.5, 1]
		shadow2OpacityAnim.duration    = 4
		shadow2OpacityAnim.repeatCount = Float.infinity
		
		var shadow2BreathAnim : CAAnimationGroup = QCMethod.groupAnimations([shadow2OpacityAnim], fillMode:fillMode)
		layers["shadow2"]?.addAnimation(shadow2BreathAnim, forKey:"shadow2BreathAnim")
		
		let line = layers["line"] as! CAShapeLayer
		
		////Line animation
		var lineTransformAnim            = CAKeyframeAnimation(keyPath:"transform")
		lineTransformAnim.values         = [NSValue(CATransform3D: CATransform3DIdentity), 
			 NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1))]
		lineTransformAnim.keyTimes       = [0, 1]
		lineTransformAnim.duration       = 2
		lineTransformAnim.beginTime      = 1.8
		lineTransformAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
		lineTransformAnim.repeatCount    = Float.infinity
		
        
        
		////Line animation
		var lineOpacityAnim            = CAKeyframeAnimation(keyPath:"opacity")
		lineOpacityAnim.values         = [0, 0, 1, 0]
		lineOpacityAnim.keyTimes       = [0, 0.5, 0.502, 1]
		lineOpacityAnim.duration       = 4
		lineOpacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
		lineOpacityAnim.repeatCount    = Float.infinity
		
		var lineBreathAnim : CAAnimationGroup = QCMethod.groupAnimations([lineTransformAnim, lineOpacityAnim], fillMode:fillMode)
		layers["line"]?.addAnimation(lineBreathAnim, forKey:"lineBreathAnim")
	}
	
	//MARK: - Animation Cleanup
	
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
		if identifier == "Breath"{
			QCMethod.updateValueFromPresentationLayerForAnimation((layers["effect"] as! CALayer).animationForKey("effectBreathAnim"), theLayer:(layers["effect"] as! CALayer))
			QCMethod.updateValueFromPresentationLayerForAnimation((layers["shadow2"] as! CALayer).animationForKey("shadow2BreathAnim"), theLayer:(layers["shadow2"] as! CALayer))
			QCMethod.updateValueFromPresentationLayerForAnimation((layers["line"] as! CALayer).animationForKey("lineBreathAnim"), theLayer:(layers["line"] as! CALayer))
		}
	}
	
	func removeAnimationsForAnimationId(identifier: String){
		if identifier == "Breath"{
			(layers["effect"] as! CALayer).removeAnimationForKey("effectBreathAnim")
			(layers["shadow2"] as! CALayer).removeAnimationForKey("shadow2BreathAnim")
			(layers["line"] as! CALayer).removeAnimationForKey("lineBreathAnim")
		}
	}
	
	//MARK: - Bezier Path
	
	func shadowPathWithBounds(bound: CGRect) -> UIBezierPath{
		var shadowPath = UIBezierPath(ovalInRect: bound)
		return shadowPath;
	}
	
	func shadow2PathWithBounds(bound: CGRect) -> UIBezierPath{
		var shadow2Path = UIBezierPath(ovalInRect: bound)
		return shadow2Path;
	}
	
	func linePathWithBounds(bound: CGRect) -> UIBezierPath{
		var linePath = UIBezierPath(ovalInRect: bound)
		return linePath;
	}
	
	func placeHolderPathWithBounds(bound: CGRect) -> UIBezierPath{
		var placeHolderPath = UIBezierPath(ovalInRect: bound)
		return placeHolderPath;
	}
	
	
}
