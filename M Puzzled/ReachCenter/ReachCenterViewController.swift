//
//  ReachCenterViewController.swift
//  M Puzzled
//
//  Created by Manisha on 23/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import CoreMotion


class ReachCenterViewController: UIViewController{
	
	var animator:UIDynamicAnimator? = nil
	let gravity = UIGravityBehavior()
	let collider = UICollisionBehavior()
	
	var accelerometerX: UIAccelerationValue = 0
	var accelerometerY: UIAccelerationValue = 0
	
	let motionManager = CMMotionManager()
	
	var box : UIView?
	
	func addBox(location: CGRect) {
		let newBox = UIView(frame: location)
		newBox.backgroundColor = UIColor.red
		//view.insertSubview(newBox, at: 0)
		view.addSubview(newBox)
		box = newBox
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		let skView = SKView(frame: self.view.frame)
//		let scene = ReachCenterSKScene(fileNamed: "ReachCenterSKScene")
//		print("scene \(scene)")
//		skView.presentScene(scene)
//		view.addSubview(skView)
		//circlemaze
//		var maze = Maze(trackWidth: 20, innerSpokesPerQuadrant: 6, screenSize: 500)
//		view.addSubview(maze.view)
		//--circlemaze
		
		addBox(location: CGRect(x: 100,y: 100,width: 30,height: 30))
		//createAnimatorStuff()
		startMonitoringAcceleration()
		
	}
	
	deinit {
		stopMonitoringAcceleration()
	}

	
	@IBAction func closeDidClick(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func startMonitoringAcceleration() {
		
		if motionManager.isAccelerometerAvailable {
			motionManager.startAccelerometerUpdates()
			NSLog("accelerometer updates on...")
		}
	}
	
	func stopMonitoringAcceleration() {
		
		if motionManager.isAccelerometerAvailable && motionManager.isAccelerometerActive {
			motionManager.stopAccelerometerUpdates()
			NSLog("accelerometer updates off...")
		}
	}
	
	func updatePlayerAccelerationFromMotionManager() {
		
		if let acceleration = motionManager.accelerometerData?.acceleration {
			
			let FilterFactor = 0.75
			
			accelerometerX = acceleration.x * FilterFactor + accelerometerX * (1 - FilterFactor)
			accelerometerY = acceleration.y * FilterFactor + accelerometerY * (1 - FilterFactor)
		}
	}
	
	
}
