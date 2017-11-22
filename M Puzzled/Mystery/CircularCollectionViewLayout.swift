//
//  CircularCollectionViewLayout.swift
//  M Puzzled
//
//  Created by Manisha on 14/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//


import UIKit

class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
	
	var anchorPoint = CGPoint(x: 0.5, y: 0.5)
	
	var angle: CGFloat = 0 {
		didSet {
			zIndex = Int(angle*1000000)
			transform = CGAffineTransform(rotationAngle: angle)
		}
	}
	override func copy(with zone: NSZone? = nil) -> Any {
		let copiedAttributes: CircularCollectionViewLayoutAttributes = super.copy(with: zone) as! CircularCollectionViewLayoutAttributes
		copiedAttributes.anchorPoint = self.anchorPoint
		copiedAttributes.angle = self.angle
		return copiedAttributes
	}
	
}

class CircularCollectionViewLayout: UICollectionViewLayout {
	
	let itemSize = CGSize(width: 150, height: 225)
	
	var angleAtExtreme: CGFloat {
		return collectionView!.numberOfItems(inSection: 0) > 0 ? -CGFloat(collectionView!.numberOfItems(inSection: 0)-1)*anglePerItem : 0
	}
	
	var angle: CGFloat {
		return angleAtExtreme*collectionView!.contentOffset.x/(collectionViewContentSize.width - collectionView!.bounds.width)
	}
	
	var radius: CGFloat = 500 {
		didSet {
			invalidateLayout()
		}
	}
	
	var anglePerItem: CGFloat {
		return atan(itemSize.width/radius)
	}
	
	var attributesList = [CircularCollectionViewLayoutAttributes]()
	override var collectionViewContentSize: CGSize{
		collectionView?.clipsToBounds = true
		return CGSize(width: CGFloat(collectionView!.numberOfItems(inSection: 0))*itemSize.width,
		              height: collectionView!.bounds.height)
	}
	
	
	override func prepare() {
		super.prepare()
		let centerX = collectionView!.contentOffset.x + (collectionView!.bounds.width/2.0)
		let anchorPointY = ((itemSize.height/2.0) + radius)/itemSize.height
		let theta = atan2(collectionView!.bounds.width/2.0, radius + (itemSize.height/2.0) - (collectionView!.bounds.height/2.0)) //1
		var startIndex = 0
		var endIndex = collectionView!.numberOfItems(inSection: 0) - 1
		if (angle < -theta) {
			startIndex = Int(floor((-theta - angle)/anglePerItem))
		}
		endIndex = min(endIndex, Int(ceil((theta - angle)/anglePerItem)))
		if (endIndex < startIndex) {
			endIndex = 0
			startIndex = 0
		}
		print("collectionView!.numberOfItems \(endIndex)")
		if startIndex != endIndex{
		attributesList = (startIndex...endIndex).map { (i) -> CircularCollectionViewLayoutAttributes in
			let attributes = CircularCollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
			attributes.size = self.itemSize
			attributes.center = CGPoint(x: centerX, y: self.collectionView!.bounds.midY)
			attributes.angle = self.angle + (self.anglePerItem*CGFloat(i))
			attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
			print("attributes \(attributes)")
			return attributes
		}
		}
	}
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return attributesList[indexPath.row]
	}
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		print("attributesList \(attributesList)")
		return attributesList
	}
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
}
