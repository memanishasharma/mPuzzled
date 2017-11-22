//
//  StarRateView.swift
//  Hello English
//
//  Created by Manisha on 11/07/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//


@objc public protocol StarRatingViewDelegate {
	func starRatingView(ratingView: StarRateView, didUpdate rating: Int)
}

public class StarRateView:UIView{
	
	public weak var delegate: StarRatingViewDelegate?
	private var emptyImageViews: [UIImageView] = []
	private var fullImageViews: [UIImageView] = []
	
	public var emptyImage: UIImage? {
		didSet {
			for imageView in emptyImageViews {
				imageView.image = emptyImage
			}
			refresh()
		}
	}
	
	public var fullImage: UIImage? {
		didSet {
			for imageView in fullImageViews {
				imageView.image = fullImage
			}
			refresh()
		}
	}
	var imageContentMode: UIViewContentMode = UIViewContentMode.ScaleAspectFit
	public var maxRating: Int = 5
	public var minRating:Int = 0
	
	//public var _minImageSize: CGSize = CGSize(width: 5.0, height: 5.0)
	
	//private var minImageSize: CGSize = CGSize(width: 5.0, height: 5.0)
	public var minImageSize: CGSize {
		
		get {
			if isPad(){
				return CGSize(width: 48.0, height: 48.0)
			}else{
				return CGSize(width: 24.0, height: 24.0)
			}
		}
	}
	
	public var rating: Int = 0 {
		didSet {
			if rating != oldValue {
				refresh()
			}
		}
	}
	 public var editable: Bool = true
	
	required override public init(frame: CGRect) {
		super.init(frame: frame)
		
		initImageViews()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		initImageViews()
	}
	
	private func initImageViews() {
		guard emptyImageViews.isEmpty && fullImageViews.isEmpty else {
			return
		}
		
		for _ in 0..<maxRating {
			let emptyImageView = UIImageView()
			emptyImageView.contentMode = imageContentMode
			emptyImageView.image = emptyImage
			emptyImageViews.append(emptyImageView)
			addSubview(emptyImageView)
			
			let fullImageView = UIImageView()
			fullImageView.contentMode = imageContentMode
			fullImageView.image = fullImage
			fullImageViews.append(fullImageView)
			addSubview(fullImageView)
		}
	}
	
	private func removeImageViews() {
		for i in 0..<emptyImageViews.count {
			var imageView = emptyImageViews[i]
			imageView.removeFromSuperview()
			imageView = fullImageViews[i]
			imageView.removeFromSuperview()
		}
		emptyImageViews.removeAll(keepCapacity: false)
		fullImageViews.removeAll(keepCapacity: false)
	}
	
	private func refresh() {
		for i in 0..<fullImageViews.count {
			let imageView = fullImageViews[i]
			
			if rating >= i+1 {
				imageView.hidden = false
			} else {
				imageView.hidden = true
			}
			
		}
	}
	
	private func sizeForImage(image: UIImage, inSize size: CGSize) -> CGSize {
		let imageRatio = image.size.width / image.size.height
		let viewRatio = size.width / size.height
		
		if imageRatio < viewRatio {
			let scale = size.height / image.size.height
			let width = scale * image.size.width
			
			return CGSizeMake(width, size.height)
		} else {
			let scale = size.width / image.size.width
			let height = scale * image.size.height
			
			return CGSizeMake(size.width, height)
		}
	}
	
	private func updateLocation(touch: UITouch) {
		guard editable else {
			return
		}
		
		let touchLocation = touch.locationInView(self)
		var newRating = 0
		for i in (maxRating-1).stride(through: 0, by: -1) {
			let imageView = emptyImageViews[i]
			guard touchLocation.x > imageView.frame.origin.x else {
				continue
			}
			
			//let newLocation = imageView.convertPoint(touchLocation, fromView: self)
			newRating = i + 1
			
			break
		}
		
		rating = newRating < minRating ? minRating : newRating
	}
	
	override public func layoutSubviews(){
		super.layoutSubviews()
		
		guard let emptyImage = emptyImage else {
			return
		}
		
		//let desiredImageWidth = frame.size.width / CGFloat(emptyImageViews.count)
		//let maxImageWidth = max(minImageSize.width, desiredImageWidth)
		let maxImageWidth = minImageSize.width
		let maxImageHeight = minImageSize.width
		//let maxImageHeight = max(minImageSize.height, frame.size.height)
		let imageViewSize = sizeForImage(emptyImage, inSize: CGSizeMake(maxImageWidth, maxImageHeight))
		let imageXOffset = (frame.size.width - (imageViewSize.width * CGFloat(emptyImageViews.count))) /
			CGFloat((emptyImageViews.count - 1))
		
		for i in 0..<maxRating {
			let imageFrame = CGRectMake(i == 0 ? 0 : CGFloat(i)*(imageXOffset+imageViewSize.width), 0, imageViewSize.width, imageViewSize.height)
			
			var imageView = emptyImageViews[i]
			imageView.frame = imageFrame
			
			imageView = fullImageViews[i]
			imageView.frame = imageFrame
		}
		
		refresh()
	}
	
	override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		updateLocation(touch)
	}
	
	override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touch = touches.first else {
			return
		}
		updateLocation(touch)
	}
	
	override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		delegate?.starRatingView(self, didUpdate: rating)
	}
}
