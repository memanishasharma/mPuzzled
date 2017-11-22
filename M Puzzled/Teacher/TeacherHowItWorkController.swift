//
//  TeacherHowItWorkController.swift
//  Hello English
//
//  Created by Manisha on 17/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

class TeacherHowItWorkController:CAViewController{
	
	@IBOutlet var textLabel: UILabel!
	
	@IBOutlet var closeButton: UIButton!
	
	@IBOutlet var navHeaderLabel: UILabel!
	
	var howItWorkText = ""
	var popToViewController:UIViewController!
	
	override func viewDidLoad(){
		
		super.viewDidLoad()
		
		let strings = howItWorkText.split("\n")
		closeButton.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
		
		if let fontt = textLabel.font{
			let attributesDictionary = [NSFontAttributeName : fontt]
			let fullAttributedString = NSMutableAttributedString(string: "", attributes: attributesDictionary)
			
			for string: String in strings{
				let bulletPoint: String = "\u{2022}"
				let formattedString: String = "\(bulletPoint) \(string)\n"
				let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: formattedString)
				
				let paragraphStyle = createParagraphAttribute()
				attributedString.addAttributes([NSParagraphStyleAttributeName: paragraphStyle], range: NSMakeRange(0, attributedString.length))
				
				fullAttributedString.appendAttributedString(attributedString)
			}
			textLabel.attributedText = fullAttributedString
		}
		
	}
	
	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		
	}
	func createParagraphAttribute() ->NSParagraphStyle{
		var paragraphStyle: NSMutableParagraphStyle
		paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
		paragraphStyle.tabStops = [NSTextTab(textAlignment: .Left, location: 15, options: NSDictionary() as! [String : AnyObject])]
		paragraphStyle.defaultTabInterval = 15
		paragraphStyle.firstLineHeadIndent = 0
		paragraphStyle.headIndent = 15
		
		return paragraphStyle
	}
	
	func buttonClicked(sender:UIButton){
		
		if sender == closeButton{
			if let popToViewController = self.popToViewController
				where self.navigationController?.viewControllers.contains(popToViewController) == true {
				self.navigationController?.popToViewController(popToViewController, animated: true)
			} else {
				self.navigationController?.popToRootViewControllerAnimated(true)
			}
		}
	}
}
