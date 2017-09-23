//
//  ContainerViewController.swift
//  M Puzzled
//
//  Created by Manisha on 20/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//


import UIKit
import QuartzCore

enum SlideOutState {
	case BothCollapsed
	case LeftPanelExpanded
	case RightPanelExpanded
}
@objc
protocol CenterViewControllerDelegate {
	@objc optional func toggleLeftPanel()
	@objc optional func toggleRightPanel()
	@objc optional func collapseSidePanels()
}
class ContainerViewController: UIViewController {
	
	var centerNavigationController: UINavigationController!
	var centerViewController: MysteryViewController!
	var puzzleData:[String:NSObject]?
	
	var currentState: SlideOutState = .BothCollapsed {
		didSet {
			let shouldShowShadow = currentState != .BothCollapsed
			showShadowForCenterViewController(shouldShowShadow: shouldShowShadow)
		}
	}
	
	var leftViewController: LeftViewController?
	var rightViewController: RightViewController?
	
	let centerPanelExpandedOffset: CGFloat = 60
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.topLayoutGuide.heightAnchor.constraint(equalToConstant: 0)
		//self.navigationController?.setNavigationBarHidden(true, animated: false)
		centerViewController = UIStoryboard.centerViewController(puzzleData: self.puzzleData)
		centerViewController.delegate = self
		
		// wrap the centerViewController in a navigation controller, so we can push views to it
		// and display bar button items in the navigation bar
		centerNavigationController = UINavigationController(rootViewController: centerViewController)
		view.addSubview(centerNavigationController.view)
		addChildViewController(centerNavigationController)
		
		centerNavigationController.didMove(toParentViewController: self)
		centerNavigationController.setNavigationBarHidden(true, animated: true)
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
		
		centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
		//centerNavigationController.view.gestureRecognizers = [panGestureRecognizer]
	}
	
}

// MARK: CenterViewController delegate

extension ContainerViewController: CenterViewControllerDelegate {
	
	func toggleLeftPanel() {
		let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
		
		if notAlreadyExpanded {
			addLeftPanelViewController()
		}
		
		animateLeftPanel(shouldExpand: notAlreadyExpanded)
	}
	
	func toggleRightPanel() {
		let notAlreadyExpanded = (currentState != .RightPanelExpanded)
		
		if notAlreadyExpanded {
			addRightPanelViewController()
		}
		
		animateRightPanel(shouldExpand: notAlreadyExpanded)
	}
	
	func collapseSidePanels() {
		switch (currentState) {
		case .RightPanelExpanded:
			toggleRightPanel()
		case .LeftPanelExpanded:
			toggleLeftPanel()
		default:
			break
		}
	}
	
	func addLeftPanelViewController() {
		if (leftViewController == nil) {
			leftViewController = UIStoryboard.leftViewController()
			//leftViewController!.animals = Animal.allCats()
			
			addChildSidePanelController(sidePanelController: leftViewController!)
		}
	}
	
	func addChildSidePanelController(sidePanelController: UIViewController) {
		//sidePanelController.delegate = centerViewController as! MysteryViewController
		view.insertSubview(sidePanelController.view, at: 0)
		
		addChildViewController(sidePanelController)
		sidePanelController.didMove(toParentViewController: self)
		
		
	}
	
	func addRightPanelViewController() {
		if (rightViewController == nil) {
			rightViewController = UIStoryboard.rightViewController()
			//rightViewController!.animals = Animal.allDogs()
			
			addChildSidePanelController(sidePanelController: rightViewController!)
		}
	}
	
	func animateLeftPanel(shouldExpand: Bool) {
		if (shouldExpand) {
			currentState = .LeftPanelExpanded
			animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
			
		} else {
			animateCenterPanelXPosition(targetPosition: 0) { finished in
				self.currentState = .BothCollapsed
				
				self.leftViewController!.view.removeFromSuperview()
				self.leftViewController = nil;
			}
		}
	}
	
	func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
			self.centerNavigationController.view.frame.origin.x = targetPosition
		}, completion: completion)
	}
	
	func animateRightPanel(shouldExpand: Bool) {
		if (shouldExpand) {
			currentState = .RightPanelExpanded
			
			animateCenterPanelXPosition(targetPosition: -centerNavigationController.view.frame.width + centerPanelExpandedOffset)
		} else {
			animateCenterPanelXPosition(targetPosition: 0) { _ in
				self.currentState = .BothCollapsed
				
				self.rightViewController!.view.removeFromSuperview()
				self.rightViewController = nil;
			}
		}
	}
	
	func showShadowForCenterViewController(shouldShowShadow: Bool) {
		if (shouldShowShadow) {
			centerNavigationController.view.layer.shadowOpacity = 0.8
		} else {
			centerNavigationController.view.layer.shadowOpacity = 0.0
		}
	}
	
}

extension ContainerViewController: UIGestureRecognizerDelegate {
	// MARK: Gesture recognizer
	
	@objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
		let gestureIsDraggingFromLeftToRight = (gestureRecognizer.velocity(in: view).x > 0)
		
		switch(gestureRecognizer.state) {
		case .began:
			if (currentState == .BothCollapsed) {
				if (gestureIsDraggingFromLeftToRight) {
					addLeftPanelViewController()
				} else {
					addRightPanelViewController()
				}
				
				showShadowForCenterViewController(shouldShowShadow: true)
			}
		case .changed:
			gestureRecognizer.view!.center.x = gestureRecognizer.view!.center.x + gestureRecognizer.translation(in: view).x
			gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
		case .ended:
			if (leftViewController != nil) {
				// animate the side panel open or closed based on whether the view has moved more or less than halfway
				let hasMovedGreaterThanHalfway = gestureRecognizer.view!.center.x > view.bounds.size.width
				animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
			} else if (rightViewController != nil) {
				let hasMovedGreaterThanHalfway = gestureRecognizer.view!.center.x < 0
				animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
			}
		default:
			break
		}
	}
}

private extension UIStoryboard {
	class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "NavigationDrawer", bundle: Bundle.main) }
	class func mysteryStoryboard() -> UIStoryboard { return UIStoryboard(name: "Mystery", bundle: Bundle.main) }
	class func leftViewController() -> LeftViewController? {
		return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? LeftViewController
	}
	
	class func rightViewController() -> RightViewController? {
		return mainStoryboard().instantiateViewController(withIdentifier: "RightViewController") as? RightViewController
	}
	
	class func centerViewController(puzzleData: [String:NSObject]?) -> MysteryViewController? {
		
		if let cellData = puzzleData,let vc = mysteryStoryboard().instantiateViewController(withIdentifier: "MysteryViewController") as? MysteryViewController,let title = cellData["title"] as? String,let text = cellData["question"] as? String{
			vc.questionHeading = title
			vc.questionData = text
			//present(viewController, animated: true, completion: nil)
			return vc
		}
		return nil
	}
}
