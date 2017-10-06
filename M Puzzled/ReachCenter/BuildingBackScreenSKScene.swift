//
//  BuildingBackScreenSKScene.swift
//  M Puzzled
//
//  Created by Manisha on 04/10/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

struct PhysicsCategory {
	static let None      : UInt32 = 0
	static let All       : UInt32 = UInt32.max
	static let Ball   : UInt32 = 0b1       // 1
	static let Projectile: UInt32 = 0b10      // 2
}

class BuildingBackScreenSKScene: SKScene,SKPhysicsContactDelegate{
	
	var motionManager: CMMotionManager!
	
	override func didMove(to view: SKView) {
		backgroundColor = SKColor.white
		print("self.frame \(self.frame)")
		addBall()
		let borderBody2 = SKPhysicsBody(edgeLoopFrom: CGRect(x: 20,y:20,width: 350,height: 350))
		borderBody2.friction = 0
		self.physicsBody = borderBody2
		
		physicsWorld.contactDelegate = self
		
		motionManager = CMMotionManager()
		motionManager.startAccelerometerUpdates()
		
		motionManager.startDeviceMotionUpdates(
			to: OperationQueue.current!, withHandler: {
				(deviceMotion, error) -> Void in
				
				if(error == nil) {
					self.handleDeviceMotionUpdate(deviceMotion: deviceMotion!)
				} else {
					//handle the error
				}
		})
		
		//		let path = UIBezierPath()
		//		path.move(to: CGPoint(x: 120, y: 20))
		//		path.addLine(to: CGPoint(x: 230, y: 90))
		//		path.addLine(to: CGPoint(x: 240, y: 250))
		//		path.addLine(to: CGPoint(x: 100, y: 150))
		//		path.close()
		
		//let dpath = stroke1Path.cgPath
		
		//		let borderBodye = SKPhysicsBody(polygonFrom: dpath)
		//		self.physicsBody =  borderBodye
		//
		clockwiseSpiral()
		
	}
	
	func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion) {
		let attitude = deviceMotion.attitude
		let roll = degrees(attitude.roll)
		let pitch = degrees(attitude.pitch)
		let yaw = degrees(attitude.yaw)
		print("Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
		motionManager.showsDeviceMovementDisplay = true
		update()
	}
	
	func update(){
		if let accelerometerData = motionManager.accelerometerData {
			physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
		}
	}
	
	func addBall(){
		let ball = SKSpriteNode(imageNamed: "pinkBall")
		ball.position = CGPoint(x: 40, y: 50)
		ball.size = CGSize(width: 30, height: 30)
		ball.physicsBody?.allowsRotation = true
		addChild(ball)
		ball.physicsBody = SKPhysicsBody(rectangleOf: ball.size) // 1
		ball.physicsBody?.isDynamic = true // 2
		ball.physicsBody?.friction = 10
		ball.physicsBody?.restitution = 1
		ball.physicsBody?.angularDamping = 1
		ball.physicsBody?.linearDamping = 1
		ball.physicsBody?.affectedByGravity = true
		ball.physicsBody?.mass = 10
		
	}
	func degrees(_ radians:Double) -> Double {
		return 180 / Double.pi * radians
	}
	
	func random() -> CGFloat {
		return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
	}
	
	func random(min: CGFloat, max: CGFloat) -> CGFloat {
		return random() * (max - min) + min
	}
	let π = CGFloat(M_PI)
	
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
		
		let dpath = linePath.cgPath
		
		let shape = SKShapeNode()
		shape.path = dpath
		shape.position = CGPoint(x: 0, y: 0)
		shape.fillColor = UIColor.red
		shape.strokeColor = UIColor.blue
		shape.lineWidth = 10
		shape.physicsBody = SKPhysicsBody(edgeChainFrom: dpath)
		addChild(shape)
		
//		let borderBody2 = SKPhysicsBody(edgeLoopFrom: CGRect(x: 300,y:20,width: 300,height: 300))
//		borderBody2.friction = 0
//		self.physicsBody = borderBody2
		
		//self.physicsBody = SKPhysicsBody(edgeChainFrom: dpath)
//		print("dPath \(dpath) frame.midX\(frame.midX) frame.midY\(frame.midY)")
//		let shape = SKShapeNode(path: dpath)
//		//shape.path = dpath
//		shape.position = CGPoint(x: 400, y: 300)
//		shape.fillColor = UIColor.red
//		shape.strokeColor =  UIColor.black
//		shape.lineWidth = 10
//		//shape.zPosition = 2
//		//shape.physicsBody = SKPhysicsBody(edgeLoopFrom: shape.path!)
//		shape.physicsBody = SKPhysicsBody(edgeChainFrom: dpath)
//		addChild(shape)
	}
}
