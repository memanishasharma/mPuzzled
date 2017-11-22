//
//  TeacherSessionBookingViewController.swift
//  Hello English
//
//  Created by Manisha on 19/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

class TeacherSessionBookingViewController:CAViewController{
	
	@IBOutlet var backButton: UIButton!
	
	@IBOutlet var navBarHeadingLabel: UILabel!
	
	@IBOutlet var dateThumbnailView: UIImageView!
	
	@IBOutlet var dateHeadingLabel: UILabel!
	
	@IBOutlet var dateLabel: UILabel!
	
	@IBOutlet var timeThumbnailView: UIImageView!
	
	@IBOutlet var timeHeadingLabel: UILabel!
	
	@IBOutlet var timeLabel: UILabel!
	
	@IBOutlet var durationThumbnailView: UIImageView!
	
	@IBOutlet var durationHeadingLabel: UILabel!
	
	@IBOutlet var durationLabel: UILabel!

	@IBOutlet var topichumbnailView: UIImageView!
	
	@IBOutlet var topicHeadingLabel: UILabel!
	
	@IBOutlet var topicLabel: UILabel!
	
	@IBOutlet var pricehumbnailView: UIImageView!
	
	@IBOutlet var priceHeadingLabel: UILabel!
	
	@IBOutlet var priceLabel: UILabel!
	
	@IBOutlet var confirmBookingView: UIView!
	
	@IBOutlet var confirmBookingButton: UIButton!
	
	@IBOutlet var downloadIndicator: UIActivityIndicatorView!
	
	var popToViewController:UIViewController!
	var rootViewController:UIViewController!
	
	var slotData:[String:NSObject]?
	var date:String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		confirmBookingView.layer.shadowColor = UIColor.blackColor().CGColor
		confirmBookingView.layer.shadowOpacity = 1
		confirmBookingView.layer.shadowOffset = CGSizeZero
		confirmBookingView.layer.shadowRadius = 4
		backButton.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
		confirmBookingButton.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
		printDebug("slotData \(slotData)")
	
		if let data = slotData ,let startTime = data["start"] as? String,let endTime = data["end"] as? String {
		let dateFormatterGet = NSDateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		let dateFormatterPrint = NSDateFormatter()
		dateFormatterPrint.dateFormat = "MMM dd,yyyy"
		
			if let date = dateFormatterGet.dateFromString("\(startTime)"){
		    	dateLabel.text = dateFormatterPrint.stringFromDate(date)
			}else{
		    	dateLabel.text = ""
			}
			 var startDateTime = ""
			 var endDateTime = ""
				if let time = TeacherCommonClass.getLocalTimeString(startTime){
					startDateTime = time
				}
				if let time = TeacherCommonClass.getLocalTimeString(endTime){
					endDateTime = time
				}
				printDebug("startTime \(startDateTime) endTime \(endDateTime)")
				
				timeLabel.text = TeacherCommonClass.getHoursAndMinute(startDateTime,endTime:endDateTime)
			timeHeadingLabel.text = "Time"
			
		}
		
		priceHeadingLabel.text = "Price"
		priceLabel.text = "1 Credit"
		topicHeadingLabel.text = "Topic"
		topicLabel.text = "Topic will be shared 1 hour before your slot.It will be a conversational topic"
		
		durationHeadingLabel.text = "Duration"
		durationLabel.text = "20 minutes"
		downloadIndicator.stopAnimating()
		
		
		timeThumbnailView.image = UIImage(named:"ic_access_time_48pt")
		dateThumbnailView.image = UIImage(named: "ic_date_range_48pt")
		durationThumbnailView.image = UIImage(named: "ic_timelapse_48pt")
		topichumbnailView.image = UIImage(named: "ic_description_48pt")
		pricehumbnailView.image = UIImage(named: "ic_credit_card_48pt")
		
		timeThumbnailView.image? = (timeThumbnailView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
		timeThumbnailView.tintColor = UIColor.blueColorCA()
	
		dateThumbnailView.image? = (dateThumbnailView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
		dateThumbnailView.tintColor = UIColor.blueColorCA()
		
		durationThumbnailView.image? = (durationThumbnailView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
		durationThumbnailView.tintColor = UIColor.blueColorCA()
		
		topichumbnailView.image? = (topichumbnailView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
		topichumbnailView.tintColor = UIColor.blueColorCA()
		
		pricehumbnailView.image? = (pricehumbnailView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
		pricehumbnailView.tintColor = UIColor.blueColorCA()
		
	}
	
	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
	}
	
	override func viewDidDisappear(animated:Bool){
		super.viewDidDisappear(animated)
	}
	
	func buttonClicked(sender:UIButton){
		runOnUIThread({
		if sender == self.backButton{
			if let popToViewController = self.popToViewController where self.navigationController?.viewControllers.contains(popToViewController) == true {
				self.navigationController?.popToViewController(popToViewController, animated: true)
			} else {
				self.navigationController?.popToRootViewControllerAnimated(true)
			}
		}else if sender == self.confirmBookingButton{
			self.downloadIndicator.startAnimating()
			self.confirmSlotRequestSendToServer()
		}
		})
	}
	
	func confirmSlotRequestSendToServer(){
		runInBackground({
		var startHour = ""
		var startMinute = ""
		var startMH = ""
		var sendDate = ""
		
		if let data = self.slotData ,let startTime = data["start"] as? String{
			let dateFormator = NSDateFormatter()
			dateFormator.dateFormat = "yyyy-MM-dd HH:mm:ss"
			
			if let date = dateFormator.dateFromString(startTime){
				let calendar = NSCalendar.currentCalendar()
				let comp = calendar.components([.Hour,.Minute,.Day,.Month,.Year], fromDate: date)
				let hour = comp.hour
				let minute = "\(comp.minute)"
				startHour = "\(hour)"
								startMinute =  minute
				if startMinute.characters.count == 1{
					startMinute = "0" + startMinute
				}else if  startMinute.characters.count == 0{
					startMinute = "00"
				}
				startMH = startHour + ":" + startMinute
				
				sendDate = "\(comp.year)"+"-"+"\(comp.month)"+"-"+"\(comp.day)"
			}
			
			if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
				var params = [RequestParam(key: "teacher", value: "true")]
				params.append(RequestParam(key: "email", value: email))
				params.append(RequestParam(key: "date", value: sendDate))
				params.append(RequestParam(key: "slot", value: startMH))
				do{
					let response = try ServerInterface.callSync(PHPAction.BOOK_TEACHER_SESSION_BY_SLOT, params: params, jsonType: .JSONObject)
					if ((response.jsonObject?["success"] as? [String:NSObject]) != nil){
						runOnUIThread({
						Toast.makeToastWithText("Session successfully booked.", duration: .Small)
							
						if let rootViewController = self.rootViewController where self.navigationController?.viewControllers.contains(rootViewController) == true{
							self.navigationController?.popToViewController(self.rootViewController, animated: true)
						}else{
							self.navigationController?.popToRootViewControllerAnimated(true)
						}
					})
						
					}else{
						if let error = response.jsonObject?["error"] as? String{
							runOnUIThread({
							Toast.makeToastWithText(error, duration: .Small)
							})
						}
					}
				}
				catch{
					runOnUIThread({
					Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
						})
					printDebug("error")
				}
				
			}
		}
		
		runOnUIThread({
			if self.downloadIndicator.isAnimating(){
			  self.downloadIndicator.stopAnimating()
			}
		})
		})
	}
}
