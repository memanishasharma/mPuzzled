//
//  SquaremazeSkScene.swift
//  M Puzzled
//
//  Created by Manisha on 18/10/17.
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

class SquaremazeSKScene: SKScene,SKPhysicsContactDelegate{
	
	var motionManager: CMMotionManager!
	var up      :Grid<Bool> = Grid<Bool>(rows:0, columns:0, defaultValue:false)
	var right   :Grid<Bool> = Grid<Bool>(rows:0, columns:0, defaultValue:false)
	var down    :Grid<Bool> = Grid<Bool>(rows:0, columns:0, defaultValue:false)
	var left    :Grid<Bool> = Grid<Bool>(rows:0, columns:0, defaultValue:false)
	
	var visitedCells :Grid<Bool> = Grid<Bool>(rows:0, columns:0, defaultValue:false)
	
	var gridSize:Int = 10
	var screenSize:Int = Int(UIScreen.main.bounds.width)
	
	override func didMove(to view: SKView) {
		backgroundColor = SKColor.cyan
		
		addBall()
		print("self.frame.width \(self.frame.width) \(self.frame.height)")
		let borderBody2 = SKPhysicsBody(edgeLoopFrom: CGRect(x: 20,y:20,width: UIScreen.main.bounds.width,height: self.frame.width-30))
		borderBody2.friction = 0
		self.physicsBody = borderBody2
		
		physicsWorld.contactDelegate = self
		
		motionManager = CMMotionManager()
		motionManager.startAccelerometerUpdates()
		
		/**motionManager.startDeviceMotionUpdates(
			to: OperationQueue.current!, withHandler: {
				(deviceMotion, error) -> Void in
				
				if(error == nil) {
					self.handleDeviceMotionUpdate(deviceMotion: deviceMotion!)
				} else {
					//handle the error
				}
		})**/
		
		if motionManager.isDeviceMotionAvailable{
			motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
			//motionManager.showsDeviceMovementDisplay = true
			
			motionManager.startDeviceMotionUpdates(
				to: OperationQueue.current!, withHandler: {
					(deviceMotion, error) -> Void in

					if(error == nil) {
						self.handleDeviceMotionUpdate(deviceMotion: deviceMotion!)
					} else {
						//handle the error
					}
			})
		
		}
		createMaze()
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
			physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -1, dy: accelerometerData.acceleration.x * 1)
		}
	}
	
	func addBall(){
		let ball = SKSpriteNode(imageNamed: "pinkBall")
		ball.position = CGPoint(x: 40, y: 50)
		ball.size = CGSize(width: 10, height: 10)
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
	
	
	
	func createMaze(){
		visitedCells = Grid<Bool>(rows: (gridSize+2), columns: (gridSize+2), defaultValue: false)
		up = Grid<Bool>(rows: (gridSize+2), columns: (gridSize+2), defaultValue: true)
		right = Grid<Bool>(rows: (gridSize+2), columns: (gridSize+2), defaultValue: true)
		down = Grid<Bool>(rows: (gridSize+2), columns: (gridSize+2), defaultValue: true)
		left = Grid<Bool>(rows: (gridSize+2), columns: (gridSize+2), defaultValue: true)
		
		for x in 0..<gridSize+2 {
			visitedCells[x,0] = true
			visitedCells[x,gridSize+1] = true
		}
		
		for y in 0..<gridSize+2 {
			visitedCells[0,y] = true
			visitedCells[gridSize+1,y] = true
		}
		
		dropWalls(x: 1, y:1, gridSize:gridSize);
		let resizeFactor = self.frame.width/CGFloat(gridSize + 2)
		
		for x in 1..<gridSize+1 {
			for y in 1..<gridSize+1 {
				
				if (down[x,y]) {
					drawLine(from: CGPoint(x:x,y:y), to: CGPoint(x:x+1,y:y), resizeFactor:resizeFactor)
				}
				
				if (up[x,y]) {
					drawLine(from: CGPoint(x:x,y:y+1), to: CGPoint(x:x+1,y:y+1), resizeFactor:resizeFactor)
				}
				
				if (left[x,y]) {
					drawLine(from: CGPoint(x:x,y:y), to: CGPoint(x:x,y:y+1), resizeFactor:resizeFactor)
				}
				if (right[x,y]) {
					drawLine(from: CGPoint(x:x+1,y:y), to: CGPoint(x:x+1,y:y+1), resizeFactor:resizeFactor)
				}
				
			}
		}
		
	}
	
	func dropWalls(x:Int, y:Int, gridSize: Int) {
		visitedCells[x,y] = true;
		
		while (!visitedCells[x,y + 1] || !visitedCells[x + 1,y] || !visitedCells[x,y - 1] || !visitedCells[x - 1,y]) {
			
			while (true) {
				let r =  UInt32(arc4random()) % 4
				if (r == 0 && !visitedCells[x,y + 1]) {
					up[x,y] = false
					down[x,y + 1] = false
					dropWalls(x: x, y: y + 1, gridSize:gridSize)
					break
				} else if (r == 1 && !visitedCells[x + 1,y]) {
					right[x,y] = false
					left[x + 1, y] = false
					dropWalls(x: x + 1, y: y, gridSize:gridSize)
					break
				} else if (r == 2 && !visitedCells[x,y - 1]) {
					down[x,y] = false
					up[x,y - 1] = false
					dropWalls(x: x, y: y - 1, gridSize:gridSize)
					break
				} else if (r == 3 && !visitedCells[x - 1,y]) {
					left[x,y] = false
					right[x - 1,y] = false
					dropWalls(x: x - 1, y: y, gridSize:gridSize)
					break
				}
			}
		}
		
		up[1,1] = false
		down[1,1] = false
		up[gridSize,gridSize] = false
		down[gridSize,gridSize] = false
	}
	
	
	func drawLine(from:CGPoint, to:CGPoint, resizeFactor:CGFloat) {
		let path = UIBezierPath()
		path.move(to: CGPoint(x:from.x*resizeFactor, y:from.y*resizeFactor))
		path.addLine(to: CGPoint(x:to.x*resizeFactor, y:to.y*resizeFactor))
		let dpath = path.cgPath
		let shape = SKShapeNode()
		shape.path = dpath
		shape.position = CGPoint(x: 0, y: 0)
		shape.fillColor = UIColor.red
		shape.strokeColor = UIColor.blue
		shape.lineWidth = 10
		shape.physicsBody = SKPhysicsBody(edgeChainFrom: dpath)
		addChild(shape)
	}
	
}

class Grid<T> {
	var matrix:[T]
	var rows:Int
	var columns:Int
	
	init(rows:Int, columns:Int, defaultValue:T) {
		self.rows = rows
		self.columns = columns
		matrix = Array(repeating:defaultValue,count:(rows*columns))
	}
	
	func indexIsValidForRow(row: Int, column: Int) -> Bool {
		return row >= 0 && row < rows && column >= 0 && column < columns
	}
	
	subscript(col:Int, row:Int) -> T {
		get{
			assert(indexIsValidForRow(row: row, column: col), "Index out of range")
			return matrix[Int(columns * row + col)]
		}
		set{
			assert(indexIsValidForRow(row: row, column: col), "Index out of range")
			matrix[(columns * row) + col] = newValue
		}
	}
}
