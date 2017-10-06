//
//  SpiralNode.swift
//  M Puzzled
//
//  Created by Manisha on 04/10/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import SpriteKit

class SpiralNode: SKSpriteNode{
	
	let spiralShape1 = CAShapeLayer()
	let spiralShape2 = CAShapeLayer()
	let π = CGFloat(M_PI)
	
	func initializePlayer() {
		let container = SKSpriteNode.init(color: UIColor.red, size: CGSize(width: 800,height: 400))
		container.position = CGPoint(x: 300,y: 300)
		self.addChild(container)
		clockwiseSpiral()
	}
	
	
	func clockwiseSpiral(){
		
		var startAngle:CGFloat = 3*π/2
		var endAngle:CGFloat = 0
		
		var center = CGPoint(x:frame.width/3, y: frame.height/3)
		
		var radius = frame.width/90
		
		let linePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		
		for _ in 2..<10 {
			
			startAngle = endAngle
			
			switch startAngle {
			case 0, 2*π:
				center = CGPoint(x: center.x - radius/2, y: center.y)
				endAngle = π/2
			case π:
				center = CGPoint(x: center.x + radius/2, y: center.y)
				endAngle = 3*π/2
			case π/2:
				center = CGPoint(x: center.x  , y: center.y - radius/2)
				endAngle = π
			case 3*π/2:
				center = CGPoint(x: center.x, y: center.y + radius/2)
				endAngle = 2*π
			default:
				center = CGPoint(x:frame.width/3, y: frame.height/3)
			}
			
			radius = 1.5 * radius
			linePath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle,clockwise: true)
		}
		
//		// Setup the CAShapeLayer with the path, line width and stroke color
//		spiralShape1.position = center
//		spiralShape1.path = linePath.cgPath
		
		let dpath = linePath.cgPath
		
		let borderBodye = SKPhysicsBody(polygonFrom: dpath)
		self.physicsBody =  borderBodye
		
		//		spiralShape1.lineWidth = 6.0
		//
		//		spiralShape1.strokeColor = UIColor.yellow.cgColor
		//		spiralShape1.bounds = (spiralShape1.path?.boundingBoxOfPath)!
		//
		//
		//
		//		spiralShape1.fillColor = UIColor.clear.cgColor
		
		// Add the CAShapeLayer to the view's layer's sublayers
		//view?.layer.addSublayer(spiralShape1)
		
		// Animate drawing
		//drawLayerAnimation(layer: spiralShape1)
		
	}
	
	func drawLayerAnimation(layer: CAShapeLayer!){
		
		var layerShape = layer
		
		// The starting point
		layerShape?.strokeStart = 0.0
		
		// Don't draw the spiral initially
		layerShape?.strokeEnd = 0.0
		
		// Animate from 0 (no spiral stroke) to 1 (full spiral path)
		var drawAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
		drawAnimation.fromValue = 0.0
		drawAnimation.toValue = 1.0
		drawAnimation.duration = 1.6
		drawAnimation.fillMode = kCAFillModeForwards
		drawAnimation.isRemovedOnCompletion = false
		layerShape?.add(drawAnimation, forKey: nil)
	}
}
