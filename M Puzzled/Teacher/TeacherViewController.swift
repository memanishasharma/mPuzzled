//
//  TeacherViewController.swift
//  Hello English
//
//  Created by Manisha on 16/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
import CoreData

enum TeacherOptionPickerType:String{
	case BUY_CREDIT
	case SHOW_SLOT
}

class TeacherViewController:CAViewController,UITableViewDataSource,UITableViewDelegate,YTPlayerViewDelegate,ContextMenuDelegate,PassDataFromTeacherTabelCell{
	
	@IBOutlet var closeButton: UIButton!
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var buyCreditButton: ResizableButton!
	
	@IBOutlet var alertView: UIView!
	
	@IBOutlet var navBarMoreImageView: UIImageView!
	
	@IBOutlet var navBarView: UIView!
	
	@IBOutlet var downloadIndicator: UIActivityIndicatorView!
	
	@IBOutlet var footerView: UIView!
	
	@IBOutlet var footerViewHeightConst: NSLayoutConstraint!
	
	var popToViewController:UIViewController?
	var sessionData:[[String:NSObject]]?
	var howItWorks = ""
	var videotext = ""
	var baseCreditpoint:Int?
	var optionControllerType = ""
	var staticDownloadComplete = false
	var videoSetUpComplete = true
	var userBalance:[String:NSObject]?
	var isShowSessionCell = false
	var isSessionAlloted = false
	var currentSessionID = ""
	var isViewVisible = true
	var takenSessionCount:String?
	var isConnectedToNetwork = true
	var gcmFoundNil = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		closeButton.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
		
		buyCreditButton.addTarget(self, action: #selector(buyCreditClicked), forControlEvents: .TouchUpInside)
		buyCreditButton.setTitle("BUY CREDIT", forState: .Normal)
		
		alertView.hidden = true
		
		self.navBarView.gestureRecognizers = [UITapGestureRecognizer(target:self, action: #selector(showContextMenu(_:)))]
		self.navBarView.userInteractionEnabled = true
		self.navBarMoreImageView.gestureRecognizers = [UITapGestureRecognizer(target:self, action: #selector(showContextMenu(_:)))]
		self.navBarMoreImageView.userInteractionEnabled = true
		
		
		navBarMoreImageView.image? = (navBarMoreImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
		navBarMoreImageView.tintColor = UIColor.lightGrayColor()
		
		runOnUIThread({
			self.tableView.estimatedRowHeight = 200
			self.tableView.delegate = self
			self.tableView.dataSource = self
			self.tableView.reloadData()
			self.tableView.contentOffset = .zero
			self.downloadIndicator.startAnimating()
		})
		
		if isPad() {
			navBarMoreImageView.image = UIImage(named: "ic_more_vert_white_24dp_pad")
		} else {
			navBarMoreImageView.image = UIImage(named: "ic_more_vert_white_24dp")
		}
		
		self.view.layoutIfNeeded()
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		staticDownloadComplete = false
		isShowSessionCell = false
		isSessionAlloted = false
		isViewVisible = true
		callIntialSetupMethods()
		
		runOnUIThread({
			self.footerView.hidden = true
			self.footerViewHeightConst.constant = 0
			
			self.footerView.layer.shadowColor = UIColor.blackColor().CGColor
			self.footerView.layer.shadowOpacity = 1
			self.footerView.layer.shadowOffset = CGSizeZero
			self.footerView.layer.shadowRadius = 4
		})
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		hideDownLoadIndicator()
	}
	
	
	override func viewWillDisappear(animated: Bool){
		super.viewWillDisappear(animated)
		isViewVisible = false
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		self.videoSetUpComplete = true
		self.staticDownloadComplete = true
		let indexPath = NSIndexPath(forRow: 1, inSection: 0)
		if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? TeacherCell{
			cell.clearVideoResource()
		}
	}
	
	func loadTableView(){
		if isViewVisible{
			runOnUIThread({
				self.tableView.estimatedRowHeight = 200
				self.tableView.delegate = self
				self.tableView.dataSource = self
				self.tableView.contentOffset = .zero
				self.tableView.reloadData()
				
			})
		}
	}
	
	func callIntialSetupMethods(){
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
     	self.isConnectedToNetwork =  true
		dispatch_async(queue) { () -> Void in
			self.getStatusOfSession()
		}
		
		dispatch_async(queue) { () -> Void in
			
			let status = TeacherCommonClass.isConnectedToNetwork()
			if !status{
				self.isConnectedToNetwork = false
			}else{
				self.isConnectedToNetwork = true
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				self.loadTableView()
				
			})
			
		}
		
		dispatch_async(queue) { () -> Void in
			
			if let point = TeacherServerMethodCalls.fetchBaseCreditFromServer(){
				self.baseCreditpoint = point
				
			}else{
				self.isConnectedToNetwork = false
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				self.loadTableView()
				
			})
			
		}
		
		dispatch_async(queue) { () -> Void in
			if let sessionList = TeacherServerMethodCalls.fetchStaticData(){
				if let data = sessionList["videoText"] as? String {
					self.videotext = data
				}
				if let data = sessionList["howItWorks"] as? String {
					self.howItWorks = data
				}
				self.staticDownloadComplete = true
				
			}else{
				self.isConnectedToNetwork = false
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				self.loadTableView()
			})
		}
		
		dispatch_async(queue) { () -> Void in
			
			if let data = TeacherServerMethodCalls.fetchUserCreditBalance(){
				self.userBalance = data
				
			}else{
				self.isConnectedToNetwork = false
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				self.loadTableView()
				
			})
		}
		
		dispatch_async(queue) { () -> Void in
			if let response = TeacherServerMethodCalls.fetchSessionTimeFromServer(){
				if  response.count != 0 && response.count > 2{
					self.sessionData = response
					self.isShowSessionCell = true
				}
			}else{
				self.isConnectedToNetwork = false
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				self.loadTableView()
			})
		}
		
		dispatch_async(queue) { () -> Void in
			if let response = TeacherServerMethodCalls.getSessionHistory(){
				if response.count != 0{
					self.takenSessionCount = "\(response.count)"
					
				}
			}else{
				self.isConnectedToNetwork = false
			}
			dispatch_async(dispatch_get_main_queue(), {
				self.loadTableView()
			})
			
		}
	}
	
	func showContextMenu(sender:UIGestureRecognizer){
		if let view = sender.view{
			menuIconDidClick(view)
			
		}
	}
	
	
	func hideDownLoadIndicator(){
		let serialQueue = dispatch_queue_create("com.helloEnglish.hideDownloader",DISPATCH_QUEUE_SERIAL)
		dispatch_async(serialQueue,{() -> Void in
			
			if self.isViewVisible{
				let startDate = NSDate()
				while(!self.videoSetUpComplete || !self.staticDownloadComplete) {
					
					if NSDate().timeIntervalSinceDate(startDate) > 30 {
						printDebug("request time out")
						break
					}
					NSThread.sleepForTimeInterval(0.500)
				}
				dispatch_async(dispatch_get_main_queue(), {
					
					if self.downloadIndicator.isAnimating(){
						self.downloadIndicator.stopAnimating()
					}
			 })
			}
			
		})
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
	
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var count = 2
		if let data = sessionData{
			let dataCount = data.count
			
			if let data = Prefs.objectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA) as? String ,let sessionData = parseJSON(fromString: data) as? [String:NSObject]{
				if let status = sessionData["session_active"] as? String{
					if status == "pending" {
						isSessionAlloted = true
					}else if status == "true"{
						
					}else{
						isSessionAlloted = false
					}
				}
				
			}
			
			if isSessionAlloted == true{
				count += 2
			}else{
				if dataCount >= 3{
					count += 5
				}
			}
		}
		if userBalance != nil{
			count += 2
		}
		if !isConnectedToNetwork{
			isShowSessionCell = false
			count += 1
		}
		return count
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "teacherSessionInfoCell"{
			openTeacherSession()
		}
		
	}
	
	
	func getStatusOfSession(){
		
			while(self.isViewVisible) {
				let response = TeacherServerMethodCalls.getSessionStatusFromServer()
				if response{
					gcmFoundNil = false
					if let data = Prefs.objectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA) as? String ,let sessionData = parseJSON(fromString: data) as? [String:NSObject],let status = sessionData["session_active"] as? String{
						if status == "pending" {
							self.isSessionAlloted = true
							self.loadTableView()
						}else if status == "true",let sessionID = sessionData["session_id"] as? String{
							runOnUIThread({
								if self.downloadIndicator.isAnimating(){
									self.downloadIndicator.stopAnimating()
								}
								let storyBoard = UIStoryboard(name:"Teacher",bundle: nil)
								if let viewController = storyBoard.instantiateViewControllerWithIdentifier(TeacherSessionController.nameOfClass) as? TeacherSessionController{
									viewController.popToViewController = self
									viewController.currentSessionId = sessionID
									let data = self.constructChatTeacherJson()
									viewController.sessionData = data
									if self.isViewVisible{
										dispatch_async(dispatch_get_main_queue(), {
											self.navigationController?.pushViewController(viewController, animated: true)
										})
									}
								}
							})
						}else if status == "false"{
							self.isSessionAlloted = true
							self.loadTableView()
						}else{
							self.isSessionAlloted = false
							}
					}
				}else{
					gcmFoundNil = true
					self.loadTableView()
				}
				NSThread.sleepForTimeInterval(30)
			}
		
	}
	
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.row == 0{
			if let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherVideoCell") as? TeacherCell{
				cell.selectionStyle = .None
				cell.delegate = self
				return cell
			}
		}else if indexPath.row == 1{
			if let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherInfoCell") as? TeacherCell{
				
				cell.infoHeading1Label.text = videotext
				cell.howItWorkButton.addTarget(self, action: #selector(howItWork), forControlEvents: .TouchUpInside)
				cell.selectionStyle = .None
				return cell
			}
		}else if indexPath.row == 2{
			
			if !isConnectedToNetwork || gcmFoundNil{
				if let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherNoInternet") as? TeacherCell{
					cell.teacherTryAgainButton.addTarget(self, action: #selector(callIntialSetupMethods), forControlEvents: .TouchUpInside)
					
					return cell
				}
			}else{
				
				if let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherHeaderCell") as? TeacherCell{
					cell.selectionStyle = .None
					if let data = sessionData where data.count != 0{
						if isSessionAlloted{
							cell.headingLabel.text = "Pending session:"
							cell.backgroundColor = UIColor(hexString: "#E8F8F5")
						}else{
						    cell.headingLabel.text = "Next available slots"
							cell.backgroundColor = UIColor(hexString: "#FFFFFF")
						}
						cell.headingLabel.textAlignment = .Left
					}else{
						
						if let data = Prefs.objectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA) as? String ,let sessionData = parseJSON(fromString: data) as? [String:NSObject],let status = sessionData["session_active"] as? String{
							if status == "false" {
								cell.headingLabel.text = "Sorry no slots available currently,please try again later"
							}else{
								cell.headingLabel.text = ""
							}
						}else{
							cell.headingLabel.text = ""
						}
						
						cell.headingLabel.textAlignment = .Center
					}
					return cell
				}
			}
		}else if isShowSessionCell{
			
			if isSessionAlloted{
				if indexPath.row == 3{
					if let cell = self.tableView.dequeueReusableCellWithIdentifier("showActiveSession") as? TeacherCell{
						
						if let data = Prefs.objectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA) as? String ,let sessionData = parseJSON(fromString: data) as? [String:NSObject]{
							if let data = sessionData["data"] as? [[String:NSObject]] where data.count > 0{
								
								if let data = Prefs.objectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA) as? String ,let sessionData = parseJSON(fromString: data) as? [String:NSObject],let sessionID = sessionData["session_id"] as? String{
									self.currentSessionID = sessionID
								}
								var index = 0
								for i in 0..<data.count{
									
									if data[i]["session_id"] == self.currentSessionID{
										index = i
										break
									}
								}
								if let topic = data[index]["topicName"] as? String {
									//Topic will be shared 1 hour before your slot.It will be a conversational topic
									cell.topicLabel.text = topic
									if topic == ""{
										cell.topicLabel.text = "Topic will be shared 1 hour before your slot.It will be a conversational topic"
									}
								}else{
									cell.topicLabel.text = "Topic will be shared 1 hour before your slot.It will be a conversational topic"
								}
								cell.topicHeadingLabel.text = "Topic:"
								cell.dateHeadingLabel.text = "Date:"
								cell.durationHeadingLabel.text = "Duration:"
								cell.durationLabel.text = "20 minutes"
								
								if let data = self.sessionData ,let startTime = data[indexPath.row-3]["start"] as? String, let endTime  = data[indexPath.row-3]["end"] as? String{
									printDebug("indexPath.row-2 \(indexPath.row-2)")
									let dateFormatterGet = NSDateFormatter()
									dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
									
									let dateFormatterPrint = NSDateFormatter()
									dateFormatterPrint.dateFormat = "MMM dd,yyyy"
									
									if let date = dateFormatterGet.dateFromString("\(startTime)"){
										cell.dateLabel.text = dateFormatterPrint.stringFromDate(date)
									}else{
										cell.dateLabel.text = ""
									}
									var startDateTime = ""
									var endDateTime = ""
									if let time = TeacherCommonClass.getLocalTimeString(startTime){
										startDateTime = time
									}
									if let time = TeacherCommonClass.getLocalTimeString(endTime){
										endDateTime = time
									}
									
									cell.timeLabel.text = TeacherCommonClass.getHoursAndMinute(startDateTime,endTime:endDateTime)
									cell.timeHeadingLabel.text = "Time:"
									
								}
								
							}
						}
						cell.selectionStyle = .None
						cell.timeThumbnailView.image = UIImage(named:"ic_access_time_48pt")
						cell.dateThumbnailView.image = UIImage(named: "ic_date_range_48pt")
						cell.durationThumbnailView.image = UIImage(named: "ic_timelapse_48pt")
						cell.topichumbnailView.image = UIImage(named: "ic_description_48pt")
						
						cell.timeThumbnailView.image? = (cell.timeThumbnailView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
						cell.timeThumbnailView.tintColor = UIColor.blueColorCA().colorWithAlphaComponent(0.54)
						
						cell.dateThumbnailView.image? = (cell.dateThumbnailView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
						cell.dateThumbnailView.tintColor = UIColor.blueColorCA().colorWithAlphaComponent(0.54)
						
						cell.durationThumbnailView.image? = (cell.durationThumbnailView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
						cell.durationThumbnailView.tintColor = UIColor.blueColorCA().colorWithAlphaComponent(0.54)
						
						cell.topichumbnailView.image? = (cell.topichumbnailView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
						cell.topichumbnailView.tintColor = UIColor.blueColorCA().colorWithAlphaComponent(0.54)
						
						return cell
					}
				}else if indexPath.row == 4{
					if let cell = self.tableView.dequeueReusableCellWithIdentifier("userBalanceCell") as? TeacherCell{
						cell.selectionStyle = .None
						cell.reviewSessionButton.addTarget(self, action:#selector(showTeacherSessionView), forControlEvents: .TouchUpInside)
						cell.showHistoryButton.addTarget(self, action: #selector(showCreditHistroyBalance), forControlEvents: .TouchUpInside)
						
						
						if let data = self.userBalance{
							if let balance = integerValueFromJSON(data, forKey: "balance"){
								cell.leftCreditLabel.text = "\(balance)"+" Credits left"
								if balance != 0{
									self.footerView.hidden = true
									self.footerViewHeightConst.constant = 0
								}else{
									self.footerView.hidden = false
									if isPad(){
										self.footerViewHeightConst.constant = 65
									}else{
										self.footerViewHeightConst.constant = 50
									}
								}
							}
							let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
							let context = delegate.managedObjectContextMain
							if let session = takenSessionCount{
								cell.sessionTakenLabel.text = "\(session)"+" Sessions taken"
							}else if let count = ChatTeacher.getSessionCount(inContext: context){
								cell.sessionTakenLabel.text = "\(count)"+" Sessions taken"
							}else{
								cell.sessionTakenLabel.text = "Sessions taken"
							}
							
							return cell
						}
						
					}
				}
			}else{
				if indexPath.row > 2 && indexPath.row <= 5{
					if let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherSessionInfoCell") as? TeacherCell{
						if let data = sessionData{
							if var startTime = data[indexPath.row-3]["start"] as? String, var endTime  = data[indexPath.row-3]["end"] as? String{
								printDebug("indexPath.ro \(indexPath.row-2)")
								if let time = TeacherCommonClass.getLocalTimeString(startTime){
									startTime = time
								}
								if let time = TeacherCommonClass.getLocalTimeString(endTime){
									endTime = time
								}
								cell.slotTimeLabel.text = TeacherCommonClass.getTimeDiffAndYYYYMMDD(startTime,endTime:endTime)
								if let credit = baseCreditpoint{
									cell.slotCreditLabel.text = "\(credit) Credit"
								}else{
									cell.slotCreditLabel.text = "Credit"
								}
							}
							return cell
						}
					}
				}else if indexPath.row == 6{
					if let cell = self.tableView.dequeueReusableCellWithIdentifier("teacherMoreSlotCell") as? TeacherCell{
						cell.selectionStyle = .None
						cell.moreSlotButton.setTitle("MORE SLOTS...", forState: .Normal)
						cell.moreSlotButton.addTarget(self,action:#selector(showMoreSessionSlots),forControlEvents: .TouchUpInside)
						return cell
					}
				}else if indexPath.row == 7{
					if let cell = self.tableView.dequeueReusableCellWithIdentifier("userBalanceCell") as? TeacherCell{
						cell.selectionStyle = .None
						cell.reviewSessionButton.addTarget(self, action:#selector(showTeacherSessionView), forControlEvents: .TouchUpInside)
						cell.showHistoryButton.addTarget(self, action: #selector(showCreditHistroyBalance), forControlEvents: .TouchUpInside)
						
						
						if let data = self.userBalance{
							
							if let balance = integerValueFromJSON(data, forKey: "balance"){
								cell.leftCreditLabel.text = "\(balance)"+" Credits left"
								if balance != 0{
									self.footerView.hidden = true
									self.footerViewHeightConst.constant = 0
								}else{
									self.footerView.hidden = false
									if isPad(){
										self.footerViewHeightConst.constant = 65
									}else{
										self.footerViewHeightConst.constant = 50
									}
								}
							}
							
							let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
							let context = delegate.managedObjectContextMain
							if let session = takenSessionCount{
								cell.sessionTakenLabel.text = "\(session)"+" Sessions taken"
							}else if let count = ChatTeacher.getSessionCount(inContext: context){
								cell.sessionTakenLabel.text = "\(count)"+" Sessions taken"
							}else{
								cell.sessionTakenLabel.text = "Sessions taken"
							}
							
							return cell
						}
						
					}
				}
			}
		}else if !isShowSessionCell {
			
			if isConnectedToNetwork{
				if indexPath.row == 3 {
					if let cell = self.tableView.dequeueReusableCellWithIdentifier("userBalanceCell") as? TeacherCell{
						cell.selectionStyle = .None
						cell.reviewSessionButton.addTarget(self, action:#selector(showTeacherSessionView), forControlEvents: .TouchUpInside)
						cell.showHistoryButton.addTarget(self, action: #selector(showCreditHistroyBalance), forControlEvents: .TouchUpInside)
						
						
						if let data = userBalance{
							if let balance = integerValueFromJSON(data, forKey: "balance"){
								cell.leftCreditLabel.text = "\(balance)"+" Credits left"
								if balance != 0{
									self.footerView.hidden = true
									self.footerViewHeightConst.constant = 0
								}else{
									self.footerView.hidden = false
									if isPad(){
										self.footerViewHeightConst.constant = 65
									}else{
										self.footerViewHeightConst.constant = 50
									}
								}
							}
							let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
							let context = delegate.managedObjectContextMain
							
							if let session = takenSessionCount{
								cell.sessionTakenLabel.text = "\(session)"+" Sessions taken"
							}else if let count = ChatTeacher.getSessionCount(inContext: context){
								cell.sessionTakenLabel.text = "\(count)"+" Sessions taken"
							}else{
								cell.sessionTakenLabel.text = "Sessions taken"
							}
							
							return cell
						}
						
					}
				}
			}
		}
		
		return UITableViewCell()
		
	}
	func buyCreditClicked(){
		optionControllerType = TeacherOptionPickerType.BUY_CREDIT.rawValue
		performSegueWithIdentifier("showOptionPicker", sender: self)
		
	}
	
	func showMoreSessionSlots(){
		optionControllerType = TeacherOptionPickerType.SHOW_SLOT.rawValue
		self.performSegueWithIdentifier("showOptionPicker", sender: self)
	}
	
	func showTeacherSessionView(){
		self.performSegueWithIdentifier("openSessionList", sender: self)
	}
	
	func openTeacherSession(){
		performSegueWithIdentifier("openSession", sender: self)
	}
	
	func showCreditHistroyBalance(){
		self.performSegueWithIdentifier("creditHistory", sender: self)
	}
	func howItWork(){
		performSegueWithIdentifier("howItWork", sender: self)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let teacherHowItWorkController = segue.destinationViewController as? TeacherHowItWorkController {
			teacherHowItWorkController.howItWorkText = self.howItWorks
			teacherHowItWorkController.popToViewController = self
		}else if let teacherOptionPickerController = segue.destinationViewController as? TeacherOptionPickViewController{
			teacherOptionPickerController.type = optionControllerType
			teacherOptionPickerController.popToViewController = self
		}else if let teacherCreditViewController = segue.destinationViewController as? TeacherCreditHistoryViewController{
			teacherCreditViewController.popToViewController = self
		}else if let teacherSessionBookViewController = segue.destinationViewController as? TeacherSessionBookingViewController{
			teacherSessionBookViewController.popToViewController = self
			teacherSessionBookViewController.rootViewController = self
			let indexPath = self.tableView.indexPathForSelectedRow!
			if let data = self.sessionData where indexPath.row <= data.count{
				teacherSessionBookViewController.slotData = data[indexPath.row-3]
			}
			
		}else if let teacherSessionListViewController = segue.destinationViewController as? TeacherSessionListViewController{
			teacherSessionListViewController.popToViewController = self
		}
	}
	
	
	
	// MARK: Context Menu Delegate
	func menuIconDidClick(icon: UIView) {
		let storyboard = UIStoryboard(name: "Forum", bundle: nil)
		if let menuController = storyboard.instantiateViewControllerWithIdentifier(ContextMenuController.nameOfClass) as? ContextMenuController {
			
			menuController.modalPresentationStyle = .OverFullScreen
			menuController.modalTransitionStyle = .CrossDissolve
			
			var point = CGPointMake(icon.frame.width/2, icon.frame.height)
			point = icon.convertPoint(point, toView: self.navigationController?.view)
			menuController.origin = point
			var menuItemArray = JSONArray()
			
			menuItemArray.append(["image":"","item": "Credit History"])
			menuController.items = menuItemArray
			menuController.menuDelegate = self
			
			self.presentViewController(menuController, animated: true, completion: nil)
		}
	}
	
	// MARK: ContextMenuDelegate
	func menuDidClose(menu: ContextMenuController) {
		
	}
	
	func menu(menu: ContextMenuController, didSelectItem item: JSONObject, atPosition position: Int) {
		let _item: String
		if let item = item["item"] as? String {
			_item = item
		} else {
			return
		}
		let item: String = _item
		if item == "Credit History"{
			showCreditHistroyBalance()
		}
	}
	
	//MARK:Delegate PassDataFromTableCell
	func videoSetUpCompleteCall(){
		self.videoSetUpComplete = true
	}
	
	
	func constructChatTeacherJson()-> [String:String]{
		var json = [String:String]()
		if let data = Prefs.objectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA) as? String ,let sessionData = parseJSON(fromString: data) as? [String:NSObject]{
			json["sessionId"] = sessionData["session_id"] as? String
			json["teacherId"] =  sessionData["teacher_id"] as? String
			json["createdAt"] = sessionData["startTime"] as? String
			json["teacherEmail"] = sessionData["teacher_email"] as? String
			json["topicId"] = sessionData["topicId"] as? String
			json["name"] = sessionData["name"] as? String
			json["avatar"] = sessionData["avatar"] as? String
			json["startTime"] = sessionData["startTime"] as? String
			json["endTime"] = ""
			json["rating"] = ""
			json["topicName"] = sessionData["topicName"] as? String
			
			json["isSessionTaken"] = "false"
			
			if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
				json["userEmail"] = email
			}
			
			if let gcmId = Prefs.stringForKey(Prefs.KEY_GCM_REG_ID){
				json["gcmId"] = gcmId
			}
			
		}
		printDebug("json \(json)")
		return json
	}
}
