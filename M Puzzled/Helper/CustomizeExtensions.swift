//
//  CustomizeExtensions.swift
//  M Puzzled
//
//  Created by Manisha on 03/08/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import UIKit

extension UIColor {
	convenience init(netHex: String) {
		let scanner = Scanner(string: netHex)
		scanner.scanLocation = 0
		
		var rgbValue: UInt64 = 0
		
		scanner.scanHexInt64(&rgbValue)
		
		let r = (rgbValue & 0xff0000) >> 16
		let g = (rgbValue & 0xff00) >> 8
		let b = rgbValue & 0xff
		
		self.init(
			red: CGFloat(r) / 0xff,
			green: CGFloat(g) / 0xff,
			blue: CGFloat(b) / 0xff, alpha: 1
		)
	}
}

extension UIView {
	func dropShadow(){
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOpacity = 1
		self.layer.shadowOffset = CGSize.zero
		self.layer.shadowRadius = 3
	}
	
	func drawBorder(){
		self.layer.borderWidth = 2.0
		self.layer.borderColor = UIColor.white.cgColor
	}
}

extension UIImageView {
	func drawTint(color:UIColor){
		self.image = self.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
		self.tintColor = color
	}
}

extension NSObject {
	public var nameOfClass: String {
		return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
	}
}
