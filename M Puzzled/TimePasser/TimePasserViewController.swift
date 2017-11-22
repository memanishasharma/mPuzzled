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
		var count = 5
		while count>0{
			
			let view = UILabel()
			//view.frame = CGRect(x: xPoint ,y: yPoint,width: width ,height: height)
			
			view.textAlignment = .center
			
			view.backgroundColor = UIColor.random()
			view.isUserInteractionEnabled = true
			view.translatesAutoresizingMaskIntoConstraints = false
			
			parentView.addSubview(view)
			if let parentView = view.superview{
				let left = getRandomleft()
				let top = getRandomTop()
				let ld = NSLayoutConstraint(item: view,
				                            attribute: .leading,
				                            relatedBy: .equal,
				                            toItem: parentView,
				                            attribute: .leading,
				                            multiplier: 1,
				                            constant: left)
				
				let to = NSLayoutConstraint(item: view,
				                            attribute: .top,
				                            relatedBy: .equal,
				                            toItem: parentView,
				                            attribute: .top,
				                            multiplier: 1,
				                            constant: top)
				
				let w = NSLayoutConstraint(item: view,
				                           attribute: .width,
				                           relatedBy: .equal,
				                           toItem: nil,
				                           attribute: .notAnAttribute,
				                           multiplier: 1,
				                           constant: UIScreen.main.bounds.height/4)
				let h = NSLayoutConstraint(item: view,
				                           attribute: .height,
				                           relatedBy: .equal,
				                           toItem: nil,
				                           attribute: .notAnAttribute,
				                           multiplier: 1,
				                           constant: UIScreen.main.bounds.height/4)
				NSLayoutConstraint.activate([ld,to,w,h])
				self.view.layoutIfNeeded()
				view.text = String(count)+" "+String(describing: view.frame)
			}
			count = count-1
			view.gestureRecognizers = [
				UITapGestureRecognizer(target: self, action: #selector(self.didViewTapped(tapGesture:)))
			]
			randomElementArray.append(view)
		}
	}
	
	@objc func didViewTapped(tapGesture: UITapGestureRecognizer){
		print("i am clicked")
		
		if let touchedView = tapGesture.view{
			for data in randomElementArray{
				if touchedView == data{
					print("touchedViewFrame \(view.frame)")
					let viewCenterPointWRTSuperView:CGPoint =  touchedView.superview!.convert(touchedView.center, to:self.parentView)
					let viewCenter = self.parentView.center
					var finalTransaltionPoint = CGPoint(x: 0,y: 0)
					
					if viewCenterPointWRTSuperView.x < viewCenter.x{
						finalTransaltionPoint.x = -(UIScreen.main.bounds.width)
					}else{
						finalTransaltionPoint.x = (UIScreen.main.bounds.width)
					}
					
					if viewCenterPointWRTSuperView.y < viewCenter.y{
						finalTransaltionPoint.y = -(UIScreen.main.bounds.height)
					}else{
						finalTransaltionPoint.y = (UIScreen.main.bounds.height)
					}
					let touchViewIndex = self.randomElementArray.index(of: data)!
					let viewWidth = UIScreen.main.bounds.height/8
					let touchedViewTopPointl1 = data.frame.origin
					let touchedViewBottomPointr1 = CGPoint(x: data.frame.origin.x + viewWidth ,y: data.frame.origin.y + viewWidth)
					
					for i in 0..<randomElementArray.count{
						let viewArrayItem = randomElementArray[i]
						if  viewArrayItem == data{
							continue
						}
						let viewArrayItemTopPointl2 = viewArrayItem.frame.origin
						let viewArrayItemBottomPointr2 = CGPoint(x: data.frame.origin.x + viewWidth ,y: data.frame.origin.y + viewWidth)
						print("view \(String(describing: viewArrayItem.text))")
						if (touchedViewTopPointl1.x > viewArrayItemBottomPointr2.x && viewArrayItemTopPointl2.x < touchedViewBottomPointr1.x) && (touchedViewTopPointl1.y >  viewArrayItemBottomPointr2.y && viewArrayItemTopPointl2.y > touchedViewBottomPointr1.y){
							print("no touch")
						}else{
							print("touch")
						}
						
						
						
 					//if item.minX < viewCenterPointWRTSuperView.x &&  item.maxX > viewCenterPointWRTSuperView.x && item.minY < viewCenterPointWRTSuperView.y &&  item.maxY >  viewCenterPointWRTSuperView.y{
				
//					let LeftPointOfView = item.origin
//						let RightPointOfView = CGPoint(x: item.origin.x+viewWidth,y: item.origin.y+viewWidth)
//					if LeftPointOfView.x < bottomPoint.x ||  topPoint.x < RightPointOfView.x {
//
//							//print("ractangle enclosded count \(i)")
//							print("ractangle enclosded text \(String(describing: ilabel.text))")
//							for intersectView in randomElementArray{
//								if intersectView != ilabel && ilabel.bounds.intersects(intersectView.frame){
//									print("intersect")
//									if let index = self.randomElementArray.index(of: intersectView){
//										print("view \(String(describing: intersectView.text))")
//										if touchViewIndex < index{
//											print("view is below")
//											UIView.animate(withDuration: 1, delay:0.0, options: [.curveLinear], animations: {
//												view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2.0/2)).concatenating(CGAffineTransform(translationX:finalTransaltionPoint.x, y: finalTransaltionPoint.y))
//											} ,completion: { _ in
//												if let index = self.randomElementArray.index(of: data){
//													self.randomElementArray.remove(at: index)
//													//							if self.randomElementArray.isEmpty{
//													//								self.delegate.unHideViewComplete()
//													//							}
//												}
//											})
//										}else if touchViewIndex > index{
//											print("view is above ")
//
//										}else{
//
//											print("simialr touch view")
//										}
//									}
////									if let index = self.randomElementArray.index(of: data){
////										self.randomElementArray.remove(at: index)
////
////									}
//								}
//							}
//						}else{
//							print("Independent View or center not matched")
//							break
//						}
					}
				}
			}
		}
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		let touch = touches.first!
//		let location = touch.location(in: parentView)
//		print("touch poiint \(location)")
//
//		for i in 0..<randomElementArray.count{
//			let item = randomElementArray[i].frame
//			let ilabel = randomElementArray[i]
//			if item.minX < location.x &&  item.maxX > location.x && item.minY < location.y &&  item.maxY >  location.y{
//				//print("ractangle enclosded count \(i)")
//				print("ractangle enclosded text \(String(describing: ilabel.text))")
//				for view in randomElementArray{
//					if view != ilabel && ilabel.bounds.intersects(view.frame){
//						print("intersect")
//						print("view \(String(describing: view.text))")
//					}
//				}
//			}
//		}
	}
	
	func getRandomleft()-> CGFloat{
		let random = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.width-UIScreen.main.bounds.width/4)))
		return CGFloat(random)
	}
	
	func getRandomTop()-> CGFloat{
		let random = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.height-UIScreen.main.bounds.height/4)))
		return CGFloat(random)
	}

}
