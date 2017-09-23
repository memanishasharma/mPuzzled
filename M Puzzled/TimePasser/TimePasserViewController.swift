//
//  TimePasserViewController.swift
//  M Puzzled
//
//  Created by Manisha on 15/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import UIKit

class TimePasserViewController: UIViewController {
	
	@IBOutlet var parentView: UIView!
	var randomElementArray = [UILabel]()
	override func viewDidLoad(){
		super.viewDidLoad()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		generateRandomView()
	}
	
	func generateRandomView() {
		var count = 20
		while count>0{
			let xPoint = CGFloat(Float(Int(arc4random_uniform(UInt32(UIScreen.main.bounds.width-60)))))
			let yPoint = CGFloat(Float(Int(arc4random_uniform(UInt32(UIScreen.main.bounds.height-40)))))
			let width:CGFloat = 100
			let height: CGFloat = 100
			
			let view = UILabel()
			view.frame = CGRect(x: xPoint ,y: yPoint,width: width ,height: height)
			view.text = String(count)
			view.textAlignment = .center
			randomElementArray.append(view)
			view.backgroundColor = UIColor.random()
			parentView.addSubview(view)
			
			print("view.frame \(view.frame)")
			count = count-1
		}
		print("loop ended")
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		let location = touch.location(in: parentView)
		print("touch poiint \(location)")
		
		for i in 0..<randomElementArray.count{
			let item = randomElementArray[i].frame
			let ilabel = randomElementArray[i]
			if item.minX < location.x &&  item.maxX > location.x && item.minY < location.y &&  item.maxY >  location.y{
				//print("ractangle enclosded count \(i)")
				print("ractangle enclosded text \(String(describing: ilabel.text))")
				for view in randomElementArray{
					if view != ilabel && ilabel.bounds.intersects(view.frame){
						print("intersect")
						print("view \(String(describing: view.text))")
					}
				}
			}
		}
	}
}
