//
//  CircularCollectionViewCell.swift
//  M Puzzled
//
//  Created by Manisha on 14/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//


import UIKit

class CircularCollectionViewCell: UICollectionViewCell {
	
//	var imageName = "" {
//		didSet {
//			imageView!.image = UIImage(named: imageName)
//		}
//	}
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var mainView: UIView!
	@IBOutlet var cardBg: UIView!
	var id:String?
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
		contentView.layer.cornerRadius = 5
		contentView.layer.borderColor = UIColor.black.cgColor
		contentView.layer.borderWidth = 1
		contentView.layer.shouldRasterize = true
		contentView.layer.rasterizationScale = UIScreen.main.scale
		contentView.clipsToBounds = true
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func apply(_ _layoutAttributes: UICollectionViewLayoutAttributes) {
		super.apply(_layoutAttributes)
		let circularlayoutAttributes = _layoutAttributes as! CircularCollectionViewLayoutAttributes
		self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
		self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5)*(self.bounds.height)
	}
	
}
