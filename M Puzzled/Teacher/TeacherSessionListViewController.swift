//
//  TeacherSessionListViewController.swift
//  Hello English
//
//  Created by Manisha on 31/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
import CoreData

class TeacherSessionListViewController:CAViewController,UITableViewDelegate,UITableViewDataSource{
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var backButton: UIButton!
	
	@IBOutlet var refreshView: UIView!
	
	@IBOutlet var navBarHeadingLabel: UILabel!
	
	@IBOutlet var downloadIndicator: UIActivityIndicatorView!
	
	@IBOutlet var refreshImageView: UIImageView!
	
	
	var popToViewController:UIViewController!
	var sessionData:[[String: [ChatTeacher]]]?
	var teacherSessionList : [[String:NSObject]]?
	var updateFrom:Int?
	
	enum updateType:Int{
		case isFromLocal = 0
		case isFromServer = 1
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		backButton.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
		refreshView.gestureRecognizers = [UITapGestureRecognizer(target:self, action: #selector(fetchSessionListFromServer(_:)))]
		
		fetchSessionListFromServer()
		refreshImageView.image = refreshImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
		refreshImageView.tintColor = UIColor.whiteColor()
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		getSessionDataFromLocal()
		fetchSessionListFromServer()
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	func buttonClicked(sender:UIButton){
		
		if sender == backButton{
			if let popToViewController = self.popToViewController
				where self.navigationController?.viewControllers.contains(popToViewController) == true {
				self.navigationController?.popToViewController(popToViewController, animated: true)
			} else {
				self.navigationController?.popToRootViewControllerAnimated(true)
			}
		}
	}
	
	func loadTableView(){
		runOnUIThread({
			if self.downloadIndicator.isAnimating(){
				self.downloadIndicator.stopAnimating()
			}
			self.tableView.delegate = self
			self.tableView.dataSource = self
			self.tableView.estimatedRowHeight = 100
			self.tableView.reloadData()
			
		})
	}
	
	func getSessionDataFromLocal(){
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let context = delegate.managedObjectContextMain
		
		sessionData = ChatTeacher.fetchSessionList(inContext: context)
		if sessionData != nil{
			updateFrom = updateType.isFromLocal.rawValue
			loadTableView()
		}
	}
	
	func fetchSessionListFromServer(){
		
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		
		dispatch_async(queue) { () -> Void in
			let data = TeacherServerMethodCalls.getSessionHistory()
			
			if let sessionData = data{
				self.updateFrom = updateType.isFromServer.rawValue
				self.teacherSessionList = sessionData
				self.loadTableView()
				//self.updateDataBaseEntry()
			}else{
				dispatch_async(dispatch_get_main_queue(), {
					if self.downloadIndicator.isAnimating(){
						self.downloadIndicator.stopAnimating()
					}
					
				})
			}
			
		}
	}
	
	
	
	func fetchSessionListFromServer(sender:UITapGestureRecognizer){
		dispatch_async(dispatch_get_main_queue(), {
			self.downloadIndicator.startAnimating()
			if sender.view == self.refreshView{
				self.fetchSessionListFromServer()
			}
		})
	}
	
	func updateDataBaseEntry(){
		if let listData = self.teacherSessionList {
			for data in listData{
				self.constructJson(data )
			}
			self.getSessionDataFromLocal()
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let type = updateFrom where type == updateType.isFromLocal.rawValue,let data = sessionData{
			return data.count
		}else  if let type = updateFrom where type == updateType.isFromServer.rawValue,let data = teacherSessionList{
			return data.count
		}
		return 0
	}
	
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if let type = updateFrom where type == updateType.isFromLocal.rawValue{
			
			if let _data = sessionData where _data.count > indexPath.row,let data = _data[indexPath.row]["sessionData"]{
				
				let item = data[0]
				if let cell = self.tableView.dequeueReusableCellWithIdentifier("SessionCell") as? TeacherCell{
					if let startSessionTime = item.time{
						let time = TeacherCommonClass.getLocalTimeString(startSessionTime)
						cell.sessionTimeLabel.text = time
						cell.sessionHeadingLabel.text = "Teacher Session"
						
						
					}
					return cell
				}
				
			}
		}else if let type = updateFrom where type == updateType.isFromServer.rawValue{
			if let data = teacherSessionList{
				let item = data[indexPath.row]
				if let cell = self.tableView.dequeueReusableCellWithIdentifier("SessionCell") as? TeacherCell{
					if let createdAt = item["createdAt"] as? String{
						cell.sessionTimeLabel.text = createdAt
					}
					if let startSessionTime = item["createdAt"] as? String{
						let time = TeacherCommonClass.getLocalTimeString(startSessionTime)
						cell.sessionTimeLabel.text = time
						cell.sessionHeadingLabel.text = "Teacher Session"
						
						
					}
					return cell
				}
			}
		}
		return UITableViewCell()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showSessionDetail", sender: self)
	}
	func constructChatJson(item:[String:NSObject]) -> [String:String]{
		var json = [String:String]()
		json["sessionId"] = item["sessionId"] as? String
		json["teacherId"] = item["teacherId"] as? String
		json["createdAt"] = item["createdAt"] as? String
		json["teacherEmail"] = item["teacherEmail"] as? String
		json["topicId"] = item["topicId"] as? String
		json["name"] = item["name"] as? String
		json["avatar"] = item["avatar"] as? String
		json["startTime"] = item["startTime"] as? String
		json["endTime"] = item["endTime"] as? String
		json["rating"] = item["rating"] as? String
		json["topicName"] = item["topicName"] as? String
		json["isSessionTaken"] = "true"
		
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			json["userEmail"] = email
		}
		
		if let gcmId = Prefs.stringForKey(Prefs.KEY_GCM_REG_ID){
			json["gcmId"] = gcmId
		}
		
		return json
		
	}
	
	
	func constructChatTeacherJson(item:ChatTeacher)-> [String:String]{
		var json = [String:String]()
		json["sessionId"] = item.sessionId
		json["teacherId"] = item.teacher_id
		json["createdAt"] = item.time
		json["teacherEmail"] = item.teacher_email
		json["topicId"] = ""
		json["name"] = ""
		json["avatar"] = ""
		json["startTime"] = ""
		json["endTime"] = ""
		json["rating"] = ""
		json["topicName"] = ""
		json["isSessionTaken"] = "true"
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			json["userEmail"] = email
		}
		
		if let gcmId = Prefs.stringForKey(Prefs.KEY_GCM_REG_ID){
			json["gcmId"] = gcmId
		}
		return json
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let viewController = segue.destinationViewController as? TeacherSessionController{
			if let type = self.updateFrom where type == updateType.isFromServer.rawValue{
				if let indexpath = self.tableView.indexPathForSelectedRow{
					if let data = teacherSessionList where indexpath.row < data.count{
						
						let item = data[indexpath.row]
						
						let data = constructChatJson(item)
						viewController.sessionData = data
						viewController.popToViewController = self
					}
					
				}
			}
			
			if let type = self.updateFrom where type == updateType.isFromLocal.rawValue{
				if let indexpath = self.tableView.indexPathForSelectedRow{
					if let _data = sessionData,let data = _data[indexpath.row]["sessionData"]{
						
						
						let item = data[0]
						let data = constructChatTeacherJson(item)
						viewController.sessionData = data
						viewController.popToViewController = self
					}
				}
				
			}
			
		}
	}
	
	
	private func constructJson(json:[String:NSObject]){
		
		var sender = ""
		var userInfo = [NSObject:AnyObject]()
		
		userInfo["teacher_id"] = json["teacherId"]
		userInfo["from"] = ""
		userInfo["id"] =  "tempSession"
		if let item = json["id"] as? String{
			userInfo["id"] = item
		}else{
			userInfo["id"] = ""
		}
		
		if let item = json["sessionId"] as? String{
			userInfo["session_id"] = item
		}else{
			userInfo["session_id"]  = ""
		}
		
		
		var data = [String:NSObject]()
		
		if let item = json["text"] as? String where item.characters.count != 0{
			data["text"] = item
		}else{
			data["text"] = ""
		}
		
		if let item = json["duration"]{
			data["duration"] = item
			
		}else{
			data["duration"] = ""
		}
		if let item = json["type"]{
			data["type"] = item
		}else{
			data["type"] = ""
		}
		
		if let imgPath = json["imagePath"]{
			data["imagePath"] = imgPath
		}else{
			data["imagePath"] = ""
		}
		
		if let filePath = json["audioFileLink"]{
			data["filePath"] = filePath
		}else{
			data["filePath"] = ""
		}
		
		if let filePath = json["audioFileLink"]{
			data["filePath"] = filePath
		}else{
			data["filePath"] = ""
		}
		userInfo["data"] = toString(fromJSON:data) ?? ""
		
		if let time = json["createdAt"]{
			userInfo["time"] = time
		}
		
		if let userEmail = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			var senderEmail = ""
			var receiverEmail = ""
			if let item = json["receiverEmail"] as? String{
				receiverEmail = item
			}
			if let item = json["senderEmail"] as? String{
				senderEmail = item
			}
			if receiverEmail == userEmail{
				userInfo["teacher_email"] = senderEmail
				sender = senderType.SENDER_IS_TEACHER.rawValue
			}else if senderEmail == userEmail{
				sender = senderType.SENDER_IS_USER.rawValue
			}else{
				return
			}
			
		}else{
			return
		}
		userInfo["type"] = "chat_teacher_audio"
		userInfo["sub_type"] = "reply"
		ChatTeacher.processTeacherMessage(userInfo,sender:sender,isSingleEntry: false)
	}
}
