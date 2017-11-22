//
//  ResizableButton.swift
//  Hello English
//
//  Created by Manisha on 11/07/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
class ResizableButton: UIButton {
	
	override func intrinsicContentSize() -> CGSize
	{
		let labelSize = titleLabel?.sizeThatFits(CGSizeMake(self.frame.size.width, CGFloat.max)) ?? CGSizeZero
		let desiredButtonSize = CGSizeMake(labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
		
		return desiredButtonSize
}
}
