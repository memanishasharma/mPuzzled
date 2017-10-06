//
//  CircleCenterGameViewController.swift
//  M Puzzled
//
//  Created by Manisha on 04/10/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class CircleCenterGameViewController  : UIViewController{
	
	@IBOutlet var gameView: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let scene = BuildingBackScreenSKScene(size: gameView.bounds.size)
		let skView = gameView as! SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .resizeFill
		
		skView.showsPhysics = true
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
		//scene.scaleMode = .aspectFit
		
		skView.presentScene(scene)
		
	}
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	@IBAction func closeDidClick(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let value = UIInterfaceOrientation.landscapeLeft.rawValue
		UIDevice.current.setValue(value, forKey: "orientation")
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		let value = UIInterfaceOrientation.portrait.rawValue
		UIDevice.current.setValue(value, forKey: "orientation")
	}
	
	
	override var shouldAutorotate: Bool{
		return false
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
		return UIInterfaceOrientationMask.landscape
	}
}
