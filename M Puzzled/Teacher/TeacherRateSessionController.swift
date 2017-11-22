//
//  TeacherRateSessionController.swift
//  Hello English
//
//  Created by Manisha on 11/07/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation


class TeacherRateSessionController: CAViewController,StarRatingViewDelegate {
	
	@IBOutlet var starRatingView: StarRateView!

	@IBOutlet var teacherNameLabel: UILabel!
	
	@IBOutlet var teacherAvatarImageView: UIImageView!
	
	@IBOutlet var sessionTimeLabel: UILabel!
	
	@IBOutlet var commentView: UIView!
	
	@IBOutlet var commentTextField: UITextField!
	
	@IBOutlet var submitButton: ResizableButton!
	
	@IBOutlet var closeButton: UIButton!
	
	var currentSessionId:String?
	var teacherName: String = ""
	var sessionTime:String = ""
	var teacherAvatar:String = ""
	var rating :String = "0"
	
	override func viewDidLoad(){
		super.viewDidLoad()
		
		self.starRatingView.emptyImage = UIImage(named: "ic_star_border_black_24dp")
		self.starRatingView.fullImage = UIImage(named: "ic_star_black_24dp")
		self.starRatingView.delegate = self
		self.starRatingView.contentMode = UIViewContentMode.ScaleAspectFit
		self.starRatingView.maxRating = 5
		self.starRatingView.minRating = 0
		self.starRatingView.rating = 0
		self.starRatingView.editable = true
		
		teacherNameLabel.text = teacherName
		teacherAvatarImageView.image = UIImage(named: teacherAvatar)
		sessionTimeLabel.text = sessionTime
		
       self.closeButton.hidden = true
	}
	
	@IBAction func closeButtonClicked(sender: AnyObject) {
		//self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func submitButtonClicked(sender: AnyObject) {
	
		//runInBackground({
		let localQueue = NSOperationQueue()
		
		let operation1 = NSBlockOperation(block: {
			var json = [String:NSObject]()
			json["comment"] = self.commentTextField.text
			
			if let _currentSessionId = self.currentSessionId{
			 json["sessionId"] = _currentSessionId
			}
			json["rating"] = self.rating
			
			TeacherServerMethodCalls.updateSessionRating(json)
		})
		localQueue.addOperation(operation1)
		
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func starRatingView(ratingView: StarRateView, didUpdate rating: Int) {
		self.rating = "\(self.starRatingView.rating)"
		printDebug("self.floatRatingView.rating \(self.starRatingView.rating)")
	}
}
