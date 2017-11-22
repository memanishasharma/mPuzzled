//
//  CircleView.swift
//  Hello English
//
//  Created by Manisha on 06/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CircleView: UIView , CAAnimationDelegate{
	@IBInspectable var lineWidth: CGFloat = 4 {
		didSet {
			circleLayer.lineWidth = lineWidth
			setNeedsLayout()
		}
	}
	@IBInspectable var animating: Bool = true {
		didSet {
			updateAnimation()
		}
	}
	let circleLayer = CAShapeLayer()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	func setup() {
		circleLayer.lineWidth = lineWidth
		circleLayer.fillColor = nil
		circleLayer.strokeColor = UIColor(hexString: "#777777").CGColor
		layer.addSublayer(circleLayer)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let center = CGPoint(x: bounds.midX, y: bounds.midY)
		let radius = min(bounds.width, bounds.height) / 2 - circleLayer.lineWidth/2
		
		let startAngle = CGFloat(-M_PI_2)
		let endAngle = startAngle + CGFloat(M_PI * 2)
		let path = UIBezierPath(arcCenter: CGPointZero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		
		circleLayer.position = center
		circleLayer.path = path.CGPath
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		circleLayer.strokeColor = UIColor.greenColorCA().CGColor
	}
	func  tintColorChange(){
		circleLayer.strokeColor = UIColor(hexString: "#777777").CGColor
	}
	let strokeEndAnimation: CAAnimation = {
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.fromValue = 0
		animation.toValue = 1
		animation.duration = 2
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		
		let group = CAAnimationGroup()
		group.duration = 2.5
		group.repeatCount = MAXFLOAT
		group.animations = [animation]
		
		return group
	}()
	
	let strokeStartAnimation: CAAnimation = {
		let animation = CABasicAnimation(keyPath: "strokeStart")
		animation.beginTime = 0.5
		animation.fromValue = 0
		animation.toValue = 1
		animation.duration = 2
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		
		let group = CAAnimationGroup()
		group.duration = 2.5
		group.repeatCount = MAXFLOAT
		group.animations = [animation]
		
		return group
	}()
	let rotationAnimation: CAAnimation = {
		let animation = CABasicAnimation(keyPath: "transform.rotation.z")
		animation.fromValue = 0
		animation.toValue = M_PI * 2
		animation.duration = 4
		animation.repeatCount = MAXFLOAT
		return animation
	}()
	
	func updateAnimation() {
		if animating {
			circleLayer.addAnimation(strokeEndAnimation, forKey: "strokeEnd")
			circleLayer.addAnimation(strokeStartAnimation, forKey: "strokeStart")
			circleLayer.addAnimation(rotationAnimation, forKey: "rotation")
		}else {
			circleLayer.removeAnimationForKey("strokeEnd")
			circleLayer.removeAnimationForKey("strokeStart")
			circleLayer.removeAnimationForKey("rotation")
		}
	}
	
	func removeAnimation(){
		circleLayer.removeAnimationForKey("strokeEnd")
		circleLayer.removeAnimationForKey("strokeStart")
		circleLayer.removeAnimationForKey("rotation")
	}
	
}

