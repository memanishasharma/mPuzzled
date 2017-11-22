//
//  TeacherSessionController.swift
//  Hello English
//
//  Created by Manisha on 03/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

/**
Maintained a  track class array to store all chat data of type audio,text,image and for active download tracking
Maintained activeDownloads array of class type TeacherDownloadFileInfo. Store chat id  is of type "temp" for chat that is of type temporary which will be updated when server give response of success with chat id and url
**/

import Foundation
import CoreData
import AVFoundation
import UIKit


class TeacherSessionController:CAViewController,UITableViewDataSource,UITableViewDelegate,TeacherChatDelegate,NSURLSessionDownloadDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate,TeacherAudioCellDelegate,UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,TeacherTimerDidFinish{
	
	
	@IBOutlet var backButton: UIButton!
	
	@IBOutlet var customNavBarLabel: UILabel!
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var customNavBar: UIView!
	
	@IBOutlet var customSessionTimeHeading: UILabel!
	
	@IBOutlet var downloadIndicator: UIActivityIndicatorView!
	
	@IBOutlet var timerView: UIView!
	
	@IBOutlet var timerLabel: UILabel!
	
	@IBOutlet var sendMessageView: UIView!
	
	@IBOutlet var sendMessageImageView: UIImageView!
	
	@IBOutlet var sendMessageLeadingConstatint: NSLayoutConstraint!
	
	@IBOutlet var sendMessageWidthConstraint: NSLayoutConstraint!
	
	@IBOutlet var sendMessageTrailingConstraint: NSLayoutConstraint!
	
	@IBOutlet var audioRecordSliderView: UIView!
	
	@IBOutlet var textView: UITextView!
	
	@IBOutlet var textViewBottomConst: NSLayoutConstraint!
	
	@IBOutlet var addUserMessageView: UIView!
	
	@IBOutlet var messageSendingLoaderVIew: UIView!
	
	@IBOutlet var audioTimerLabel: UILabel!
	
	@IBOutlet var addUserMessageheightConstraint: NSLayoutConstraint!
	
	@IBOutlet var chatMessageImageView: UIImageView!
	
	@IBOutlet var avatarImageView: UIImageView!
	
	@IBOutlet var sendMessageTopConstraint: NSLayoutConstraint!
	
	@IBOutlet var blockMessageSendView: UIView!
	
	@IBOutlet var blockMessageLabel: UILabel!
	
	var currentSessionId:String?
	var chatTeacherData:[ChatTeacher]?
	
	var sessionData:[String:String]?
	var noOfRows:Int = 0
	var isSessiontaken = "false"
	
	var searchResults = [Track]()
	var activeDownloads = [String: TeacherDownloadFileInfo]()
	
	
	var timer = NSTimer()
	var popToViewController:UIViewController!
	var timerObj:TeacherSessionCountDownTimer?
	
	var recordingSession: AVAudioSession!
	var audioRecorder: AVAudioRecorder!
	var audioPlayer: AVAudioPlayer! = nil
	
	var sessionStatusData:[String:NSObject]?
	var audioDurationSeconds:Double = 0
	var audioFileNameCounter = 0
	var isAllowRecording = false
	var currentAudioFileName:NSURL?
	var audioTimer : TeacherAudioRecordTimer?
	var isRecordingStart = false
	var isRecordingCancelled = false
	var currentAudioFileUploadStatus = [String:String]()
	var currentPlayingAudioFileTag:Int?
	var playTimer = NSTimer()
	var isFirst = true
	var context:NSManagedObjectContext!
	let localQueue = NSOperationQueue()
	var dimensionUpdated = false
	var isSessionFinish = false
	var centerConstraint: NSLayoutConstraint! = nil
	
	lazy var downloadsSession: NSURLSession = {
		let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("bgSessionConfiguration")
		let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
		return session
	}()
	
	lazy var queueChatData: NSOperationQueue = {
		let  queueChatData = NSOperationQueue()
		queueChatData.maxConcurrentOperationCount = 1
		return  queueChatData
	}()
	
	
	var textSendImageObject = UIImage(named: "send_icon")
	var audioImageObject = UIImage(named: "check_appaudio")
	var playImageObject = UIImage(named: "ic_play_arrow_48pt")
	var pauseImageObject = UIImage(named: "ic_pause_48pt")
	var cancelImageObject = UIImage(named: "ic_close_black_48dp")
	var fileDownloadImageObject = UIImage(named:"ic_file_download")
	var fileUpladImageObject = UIImage(named:"ic_file_upload")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//MARK: recording permission
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		context.parentContext = delegate.managedObjectContext
		
		recordingSession = AVAudioSession.sharedInstance()
		
		do {
			try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
			try recordingSession.setActive(true)
			recordingSession.requestRecordPermission() { [unowned self] allowed in
				runOnUIThread({
					if allowed {
						self.isAllowRecording = true
					} else {
						Toast.makeToastWithText("Record permission is not enable", duration: .Small)
					}
				})
			}
		} catch {
			printDebug("in catch")
		}
		HomeController.startOperation(FCMRegistrationUpdater())
		
		textView.text = "Type a message"
		textView.textColor = UIColor.lightGrayColor()
		let notificationCenter = NSNotificationCenter.defaultCenter()
		notificationCenter.addObserver(self,
		                               selector: #selector(self.didUpdateChatMessages(_:)),
		                               name: TeacherMessagesDidUpdateNotification,
		                               object: nil)
		let notificationCenter2 = NSNotificationCenter.defaultCenter()
		notificationCenter2.addObserver(self,
		                                selector: #selector(self.lastEntryUpdation(_:)),
		                                name: TeacherEntryInsertionNotification,
		                                object: nil)
		runOnUIThread({
			self.backButton.addTarget(self, action: #selector(self.buttonClicked(_:)), forControlEvents: .TouchUpInside)
			self.textView.delegate = self
			
			NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
			NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
			
			self.sendMessageImageView.image = self.audioImageObject
			self.downloadIndicator.startAnimating()
		})
		
		self.view.gestureRecognizers = [UITapGestureRecognizer(target:self, action: #selector(hideKeyboard))]
		_ = self.downloadsSession
		
		blockMessageSendView.hidden = true
		blockMessageLabel.hidden = true
	}
	
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.textView.hidden = false
		self.audioRecordSliderView.hidden = true
		
		if let data = Prefs.objectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA) as? String{
			if let _jsonArray = parseJSON(fromString: data) as? [String:NSObject]{
				self.sessionStatusData = _jsonArray
			}
		}
		
		let operation1 = NSBlockOperation(block: {
			let response = TeacherServerMethodCalls.getSessionStatusFromServer()
			if response{
				if let data = Prefs.objectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA) as? String{
					if let _jsonArray = parseJSON(fromString: data) as? [String:NSObject]{
						self.sessionStatusData = _jsonArray
					}
				}
			}
		})
		localQueue.addOperation(operation1)
		
		let operation2 = NSBlockOperation(block: {
			self.loadPreviousChatData()
		})
		
		localQueue.addOperation(operation2)
		operation2.addDependency(operation1)
		
		
		
		self.backButton.addTarget(self, action: #selector(self.buttonClicked(_:)), forControlEvents: .TouchUpInside)
		
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if isPad(){
			self.sendMessageView.layer.cornerRadius = 60/2
			self.avatarImageView.layer.cornerRadius = 48/2
		}else{
			self.sendMessageView.layer.cornerRadius = 40/2
			self.avatarImageView.layer.cornerRadius = 24/2
		}
		self.sendMessageView.clipsToBounds = true
		self.avatarImageView.clipsToBounds = true
		startTimer()
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		playTimer.invalidate()
		audioPlayer = nil
		currentPlayingAudioFileTag = nil
		timerObj = nil
		
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.downloadsSession.invalidateAndCancel()
	}
	
	func loadPreviousChatData(){
		if let data = sessionData{
			
			if let teacherId = data["teacherId"] ,let sessionId = data["sessionId"] ,let gcmId = data["gcmId"] ,let email = data["userEmail"] {
				currentSessionId = sessionId
				self.fetchChatDataFromDatabase(sessionId)
				if isFirst{
					isFirst = false
					self.queueChatData.addOperation(TeacherSessionChatBuilder(delegate: self, teacherId: teacherId,sessionId:  sessionId,email:email ,gcmId:gcmId,context:context))
					
				}
			}
			
			NSOperationQueue.mainQueue().addOperationWithBlock({
				
				if let _isTakenStatus = data["isSessionTaken"]{
					self.isSessiontaken = _isTakenStatus
					if _isTakenStatus == "true"{
						self.customNavBar.backgroundColor = UIColor(hexString: "DDDDDD")
						self.textViewBottomConst.constant = -self.addUserMessageheightConstraint.constant-5
						self.addUserMessageView.hidden = true
						
						//Check In database for data, Parallely download data from server
					}else{
						//MARK: handle if session is active
						self.customNavBar.backgroundColor = UIColor.greenColorCA()
						self.textViewBottomConst.constant = 0
						self.addUserMessageView.hidden = false
						
					}
					self.view.layoutIfNeeded()
				}
				self.loadTableView()
				
				if let teacherName = data["name"]{
					self.customNavBarLabel.text = teacherName
				}else{
					self.customNavBarLabel.text = "Teacher"
				}
				if let teacherAvatar = data["avatar"] where teacherAvatar != "" {
					self.avatarImageView.image = UIImage(named: teacherAvatar)
				}else{
					self.avatarImageView.image = UIImage(named: "avatar_fyfn")
				}
				if let sessionTime = data["createdAt"]{
					self.customSessionTimeHeading.text = "Session taken on "+sessionTime
				}else{
					self.customSessionTimeHeading.text = "Session taken"
				}
			})
		}
		
	}
	
	func fetchChatDataFromDatabase(sessionId:String){
		self.searchResults = [Track]()
		//let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		//let context = delegate.managedObjectContextMain
		let request = NSFetchRequest()
		
		request.predicate = NSPredicate(format: "sessionId = %@", sessionId)
		let sortByTime	= NSSortDescriptor(key: "time", ascending: true)
		request.sortDescriptors = [sortByTime]
		request.entity = NSEntityDescription.entityForName(ChatTeacher.nameOfClass, inManagedObjectContext: self.context)
		var chatTeacher: [ChatTeacher]?
		
		self.context.performBlockAndWait({
			do {
				chatTeacher = (try self.context.executeFetchRequest(request) as? [ChatTeacher])
			} catch {
				printDebug("in catch error fetchChatDataFromDatabase: \(error)")
			}
		})
		self.chatTeacherData = chatTeacher
		
		if let data = self.chatTeacherData where  data.count != 0{
			self.noOfRows = data.count
			
			if let chatTeacherData = self.chatTeacherData{
				for i in 0..<chatTeacherData.count{
					if let chatMessage = chatTeacherData[i].data as? String,let chatMessageData = parseJSON(fromString: chatMessage) as? [String:NSObject]{
						printDebug("time \(chatMessageData)")
						if let type = chatMessageData["type"] where type == "audio" || type == "audio_text",
							let path = chatMessageData["filePath"] as? String, let _time = chatTeacherData[i].time{
							if let id = chatTeacherData[i].id{
								self.searchResults.append(Track(previewUrl: path,id: "\(id)",type:"audio",time: _time))
							}
						}else if let type = chatMessageData["type"] where type == "image",let _time = chatTeacherData[i].time{
							if let path = chatMessageData["imagePath"] as? String {
								if let id = chatTeacherData[i].id{
									self.searchResults.append(Track(previewUrl: path,id: "\(id)",type:"image" ,time:_time))
								}
							}
						}else{
							if let id = chatTeacherData[i].id{
								self.searchResults.append(Track(previewUrl: "",id: "\(id)",type:"text",time:""))
							}
						}
					}
				}
				
			}
		}
	}
	
	func buttonClicked(sender:UIButton){
		if sender == backButton{
			
			if isSessiontaken == "true"{
				if let popToViewController = self.popToViewController
					where self.navigationController?.viewControllers.contains(popToViewController) == true {
					self.navigationController?.popToViewController(popToViewController, animated: true)
				} else {
					self.navigationController?.popToRootViewControllerAnimated(true)
				}
			}else if isSessionFinish{
				isSessionFinish = false
				let storyBoard = UIStoryboard(name:"Teacher",bundle: nil)
				if let viewController = storyBoard.instantiateViewControllerWithIdentifier(TeacherRateSessionController.nameOfClass) as? TeacherRateSessionController{
					viewController.modalPresentationStyle = .OverFullScreen
					viewController.modalTransitionStyle = .CrossDissolve
					viewController.currentSessionId = self.currentSessionId
					if let data = sessionData{
						if let teacherName = data["name"]{
							viewController.teacherName = teacherName
						}else{
							viewController.teacherName = "Teacher"
						}
						
						if let teacherAvatar = data["avatar"] {
							viewController.teacherAvatar = teacherAvatar
						}else{
							viewController.teacherAvatar = ""
						}
						
						if let startTime = data["startTime"] {
							viewController.sessionTime = startTime
						}else{
							viewController.sessionTime = ""
						}
						self.presentViewController(viewController, animated: true, completion: nil)
					}
				}
				
			}else{
				self.navigationController?.popToRootViewControllerAnimated(true)
			}
		}
	}
	
	func loadTableView(){
		runOnUIThread({
			self.tableView.delegate = self
			self.tableView.dataSource = self
			self.tableView.estimatedRowHeight = 100
			self.tableView.reloadData()
			if self.noOfRows > 0{
				if self.downloadIndicator.isAnimating(){
					self.downloadIndicator.stopAnimating()
				}
				self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.noOfRows-1, inSection: 0), atScrollPosition: .Bottom, animated: true)
			}
		})
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return noOfRows
	}
	
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if let data = chatTeacherData where data.count > indexPath.row{
			let chatSender = data[indexPath.row].sender
			if chatSender == senderType.SENDER_IS_USER.rawValue{
				if let chatMessage = data[indexPath.row].data as? String,let chatMessageData = parseJSON(fromString: chatMessage) as? [String:NSObject]{
					if let type = chatMessageData["type"] where type == "text"{
						if isSessiontaken == "true"{
							if let message = chatMessageData["text"] as? String
							{
								if let cell = self.tableView.dequeueReusableCellWithIdentifier("UserTextMessageCell") as? TeacherCell{
									
									cell.userTextMessageLabel.text = message
									if let time = data[indexPath.row].time{
										cell.chatTimerLabel.text = time
									}else{
										cell.chatTimerLabel.text = "22/22/22"
										
									}
									cell.selectionStyle = .None
									return cell
								}
							}
						}else{
							if let messageData = parseJSON(fromString: chatMessage) as? [String:NSObject]{
								if let cell = self.tableView.dequeueReusableCellWithIdentifier("UserTextMessageCell") as? TeacherCell{
									cell.userTextMessageLabel.text = messageData["text"] as? String
									if let time = data[indexPath.row].time{
										cell.chatTimerLabel.text = time
									}else{
										cell.chatTimerLabel.text = "22/22/22"
									}
									cell.selectionStyle = .None
									return cell
								}
							}
						}
					}else if let type = chatMessageData["type"] where type == "audio"{
						if let cell = self.tableView.dequeueReusableCellWithIdentifier("UserAudioCell") as? TeacherAudioCell{
							cell.audioTimerlabel.text = data[indexPath.row].time
							cell.backGroundChatView.backgroundColor = UIColor.whiteColor()
							cell.sliderProgressUpdater(0.0)
							for recognizer in cell.audioCircleUser.gestureRecognizers ?? [] {
								cell.audioCircleUser.removeGestureRecognizer(recognizer)
							}
							if let duration = chatMessageData["duration"] as? String,let audioDuration = (NSTimeInterval(duration)){
								cell.audioTimerlabel.text = timeString(audioDuration)
							}else{
								cell.audioTimerlabel.text = "2222"
							}
							if let time = data[indexPath.row].time {
								cell.audioPostTimeLabel.text = time
							}else{
								cell.audioPostTimeLabel.text = "1111"
							}
							if searchResults.count > indexPath.row{
								let track = searchResults[indexPath.row]
								printDebug("track \(track.previewUrl!)")
								let status = TeacherCommonClass.localFileExistsForTrack(track,currentSessionId:self.currentSessionId)
								cell.playerStateImageView.tag = indexPath.row
								
								if status == true{
									cell.delegate = self
									cell.removeAnimation()
									
									
									if let id = data[indexPath.row].id where id == "temp"{
										
										cell.playerStateImageView.image = fileUpladImageObject
										cell.audioCircleUser.gestureRecognizers = [UITapGestureRecognizer(target:cell,action:#selector(cell.uploadButtonTapped))]
										
										let track = searchResults[indexPath.row]
										
										if let urlString = track.previewUrl{
											printDebug("urlString \(urlString)")
											printDebug("currentAudioFileUploadStatus \(currentAudioFileUploadStatus)")
											for (key,_) in currentAudioFileUploadStatus{
												if key == urlString{
													cell.animateCircle()
													cell.playerStateImageView.image = playImageObject
													for recognizer in cell.audioCircleUser.gestureRecognizers ?? [] {
														cell.audioCircleUser.removeGestureRecognizer(recognizer)
													}
													cell.audioCircleUser.gestureRecognizers = [UITapGestureRecognizer(target:cell,action:#selector(cell.playButtonTapped))]
												}else{
													cell.removeAnimation()
												}
											}
										}
										
									}else{
										
										cell.audioCircleUser.gestureRecognizers = [UITapGestureRecognizer(target:cell,action:#selector(cell.playButtonTapped))]
										
										if let isPlaying = currentPlayingAudioFileTag where isPlaying == cell.playerStateImageView.tag{
											cell.playerStateImageView.image = pauseImageObject
											cell.backGroundChatView.backgroundColor = UIColor.lightBlueColorHoverCA()
											cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
											cell.chatBubbleImageView.tintColor = UIColor.lightBlueColorHoverCA()
											
										}else{
											cell.playerStateImageView.image = playImageObject
											cell.backGroundChatView.backgroundColor = UIColor.whiteColor()
											cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
											cell.chatBubbleImageView.tintColor = UIColor.whiteColor()
										}
									}
									
									
								}else{
									cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
									cell.chatBubbleImageView.tintColor = UIColor.whiteColor()
									cell.audioCircleUser.gestureRecognizers = [UITapGestureRecognizer(target:cell,action:#selector(cell.downloadTapped))]
									cell.delegate = self
									
									if let urlString = track.previewUrl{
										let data = activeDownloads[urlString]
										if data != nil && activeDownloads.count != 0{
											cell.playerStateImageView.image = cancelImageObject
											cell.animateCircle()
										}else{
											cell.removeAnimation()
											cell.playerStateImageView.image = fileDownloadImageObject
										}
									}else{
										printDebug("track.previewUrl is nil")
									}
								}
							}
							
							cell.selectionStyle = .None
							cell.layoutSubviews()
							
							return cell
						}
					}
				}
			}else if chatSender == senderType.SENDER_IS_TEACHER.rawValue{
				if let chatMessage = data[indexPath.row].data as? String,let chatMessageData = parseJSON(fromString: chatMessage) as? [String:NSObject]{
					if let type = chatMessageData["type"] where type == "text"{
						if let message = chatMessageData["text"] as? String,let messageData = parseJSON(fromString: message) as? [[String:NSObject]] {
							if let cell = self.tableView.dequeueReusableCellWithIdentifier("TeacheTextMessageCell") as? TeacherCell{
								//MARK: Check for no of elements
								let messageString = NSMutableAttributedString()
								for i in 0..<messageData.count{
									if let type = messageData[i]["type"] as? String{
										
										if type == "normal"{
											if let message = messageData[i]["text"] as? String{
												let attributedMessage = NSMutableAttributedString(string: message, attributes: nil)
												messageString.appendAttributedString(attributedMessage)
											}
										}else if type == "strike"{
											if let message = messageData[i]["text"] as? String{
												let fontSize:CGFloat = 17.0
												let attributes = [
													NSFontAttributeName: UIFont(name: "Georgia", size: fontSize)!,
													NSForegroundColorAttributeName: UIColor.orangeColor(),
													NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)
												]
												
												let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
												let range = (message as NSString).rangeOfString(message)
												attributedMessage.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColorCA() , range: range)
												messageString.appendAttributedString(attributedMessage)
												
											}
										}else if type == "correction"{
											if let message = messageData[i]["text"] as? String{
												
												let attributedMessage = NSMutableAttributedString(string: message, attributes: nil)
												
												let range = (message as NSString).rangeOfString(message)
												attributedMessage.addAttribute(NSForegroundColorAttributeName, value: UIColor.yellowColorCA() , range: range)
												messageString.appendAttributedString(attributedMessage)
											}
										}
										
									}
								}
								
								cell.teacherTextMessageLabel.attributedText = messageString
								cell.selectionStyle = .None
								if isSessiontaken == "true"{
									cell.backGroundChatView.backgroundColor = UIColor(hexString: "#DDDDDD")
									cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
									cell.chatBubbleImageView.tintColor = UIColor(hexString: "#DDDDDD")
									
								}else{
									cell.backGroundChatView.backgroundColor = UIColor.greenColorCA()
									cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
									cell.chatBubbleImageView.tintColor = UIColor.greenColorCA()
									
								}
								if let time = data[indexPath.row].time {
									cell.chatTimerLabel.text = time
								}else{
									cell.chatTimerLabel.text = "22/22/22"
								}
								return cell
								
							}
						}
					}else if let type = chatMessageData["type"] where type == "audio" || type == "audio_text" {
						
						if let cell = self.tableView.dequeueReusableCellWithIdentifier("TeacherAudioCell") as? TeacherAudioCell{
							
							cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
							cell.chatBubbleImageView.tintColor = UIColor.lightGrayColor()
							
							cell.removeAnimation()
							cell.sliderProgressUpdater(0.0)
							
							cell.audioTimerlabel.text = data[indexPath.row].time
							
							if type == "audio_text",let message = chatMessageData["text"] as? String,let jsonObject = parseJSON(fromString: message) as? [[String:NSObject]] where jsonObject[0]["text"] as? String != ""{
								cell.textAudioLabel.text = jsonObject[0]["text"] as? String
								cell.textAudioHeightConstraint.constant = 25
							}else{
								cell.textAudioLabel.text = ""
								cell.textAudioHeightConstraint.constant = 0
							}
							
							if let duration = integerValueFromJSON(chatMessageData, forKey: "duration"),let audioDuration = NSTimeInterval("\(duration)"){
								
								cell.audioTimerlabel.text = timeString(audioDuration)
								
							}else{
								cell.audioTimerlabel.text = "2222"
								
							}
							if let time = data[indexPath.row].time {
								cell.audioPostTimeLabel.text = time
							}else{
								cell.audioPostTimeLabel.text = "1111"
							}
							if isSessiontaken == "true"{
								cell.backGroundChatView.backgroundColor = UIColor(hexString: "#DDDDDD")
								cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
								cell.chatBubbleImageView.tintColor = UIColor(hexString: "#DDDDDD")
								
							}else{
								cell.backGroundChatView.backgroundColor = UIColor.greenColorCA()
								cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
								cell.chatBubbleImageView.tintColor = UIColor.greenColorCA()
								
							}
							if searchResults.count > indexPath.row{
								let track = searchResults[indexPath.row]
								let status = TeacherCommonClass.localFileExistsForTrack(track,currentSessionId: self.currentSessionId)
								
								cell.playerStateImageView.tag = indexPath.row
								if status == true{
									for recognizer in cell.audioCircleTeacher.gestureRecognizers ?? [] {
										cell.audioCircleTeacher.removeGestureRecognizer(recognizer)
									}
									
									cell.audioCircleTeacher.gestureRecognizers = [UITapGestureRecognizer(target:cell,action:#selector(cell.playButtonTapped))]
									cell.delegate = self
									if let isPlaying = currentPlayingAudioFileTag where isPlaying == cell.playerStateImageView.tag{
										cell.playerStateImageView.image = pauseImageObject
										cell.backGroundChatView.backgroundColor = UIColor.lightBlueColorHoverCA()
										cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
										cell.chatBubbleImageView.tintColor = UIColor.lightBlueColorHoverCA()
									}else{
										cell.playerStateImageView.image = playImageObject
										
										if isSessiontaken == "true"{
											cell.backGroundChatView.backgroundColor = UIColor(hexString: "#DDDDDD")
											cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
											cell.chatBubbleImageView.tintColor = UIColor(hexString: "#DDDDDD")
											
										}else{
											cell.backGroundChatView.backgroundColor = UIColor.greenColorCA()
											cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
											cell.chatBubbleImageView.tintColor = UIColor.greenColorCA()
											
										}
									}
								}else{
									for recognizer in cell.audioCircleTeacher.gestureRecognizers ?? [] {
										cell.audioCircleTeacher.removeGestureRecognizer(recognizer)
									}
									
									cell.audioCircleTeacher.gestureRecognizers = [UITapGestureRecognizer(target:cell,action:#selector(cell.downloadTapped))]
									cell.delegate = self
									
									if let urlString = track.previewUrl{
										let data = activeDownloads[urlString]
										if data != nil{
											for recognizer in cell.audioCircleTeacher.gestureRecognizers ?? [] {
												cell.audioCircleTeacher.removeGestureRecognizer(recognizer)
											}
											cell.audioCircleTeacher.gestureRecognizers = [UITapGestureRecognizer(target:cell,action:#selector(cell.cancelTapped(_:)))]
											cell.playerStateImageView.image = cancelImageObject
											
											cell.animateCircle()
											
										}else{
											cell.removeAnimation()
											cell.playerStateImageView.image = fileDownloadImageObject
										}
									}else{
										printDebug("track.previewUrl is nil")
									}
								}
							}
							cell.layoutIfNeeded()
							cell.selectionStyle = .None
							return cell
						}
					}else if let type = chatMessageData["type"] where type == "image"{
						if let cell = self.tableView.dequeueReusableCellWithIdentifier("ImageMessageCell") as? TeacherAudioCell{
							
							if searchResults.count > indexPath.row{
								let track = searchResults[indexPath.row]
								if let urlString = track.previewUrl{
									let data = activeDownloads[urlString]
									if data != nil{
										//cell.downloadOverlayView.hidden = true
										cell.downloadButton.hidden = true
										cell.downloadingView.hidden = false
									}else{
										cell.downloadButton.hidden = false
										//cell.downloadOverlayView.hidden = false
										cell.downloadingView.hidden = true
									}
								}
							}
							cell.downloadOverlayView.gestureRecognizers = [UITapGestureRecognizer(target:cell,action:#selector(cell.downloadTapped))]
							cell.delegate = self
							
							if isSessiontaken == "true"{
								cell.backGroundChatView.backgroundColor = UIColor(hexString: "#AAAAAA")
								cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
								cell.chatBubbleImageView.tintColor = UIColor(hexString: "#AAAAAA")
								
							}else{
								cell.backGroundChatView.backgroundColor = UIColor.greenColorCA()
								cell.chatBubbleImageView.image = cell.chatBubbleImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
								cell.chatBubbleImageView.tintColor = UIColor.greenColorCA()
								
							}
							
							if searchResults.count > indexPath.row{
								let track = searchResults[indexPath.row]
								
								let status = TeacherCommonClass.localFileExistsForTrack(track,currentSessionId:self.currentSessionId)
								if status == true,let urlString = track.previewUrl ,let _currentSessionId = self.currentSessionId,let url = TeacherCommonClass.localFilePathForUrl(urlString,currentSessionId:_currentSessionId){
									cell.chatImageView.image = TeacherCommonClass.getImage(url)
									cell.contentView.bringSubviewToFront(cell.chatImageView)
									cell.downloadOverlayView.hidden = true
								}else{
									cell.chatImageView.image = UIImage(named: "image_placeholder")
									cell.downloadOverlayView.hidden = false
								}
							}
							
							if let time = data[indexPath.row].time{
								cell.chatTimerLabel.text = time
							}else{
								cell.chatTimerLabel.text = "22/22/22"
							}
							
							cell.setNeedsDisplay()
							cell.layoutIfNeeded()
							cell.selectionStyle = .None
							
							return cell
						}
					}
				}
			}else{
				printDebug("Else condition met for senderType")
			}
		}
		
		return UITableViewCell()
	}
	
	
	
	//Mark:Delegate method teacherSessionChatBuilder
	func chatDataFetchedComplete(success:Bool){
		runOnUIThread({
			if self.downloadIndicator.isAnimating(){
				self.downloadIndicator.stopAnimating()
			}
			let operation2 = NSBlockOperation(block: {
				self.loadPreviousChatData()
			})
			
			self.localQueue.addOperation(operation2)
			// self.loadPreviousChatData()
		})
	}
	
	func startDownload(track: Track) {
		if track.id != nil{
			if let urlString = track.previewUrl, let url =  NSURL(string: urlString),let id = track.id {
				let download = TeacherDownloadFileInfo(url: urlString,id:id)
				download.downloadTask = downloadsSession.downloadTaskWithURL(url)
				download.downloadTask!.resume()
				download.isDownloading = true
				activeDownloads[download.url] = download
			}
		}
		
	}
	
	func pauseDownload(track: Track) {
		if let urlString = track.previewUrl,
			let download = activeDownloads[urlString] {
			if(download.isDownloading) {
				download.downloadTask?.cancelByProducingResumeData { data in
					if data != nil {
						download.resumeData = data
					}
				}
				download.isDownloading = false
			}
		}
	}
	
	func cancelDownload(track: Track) {
		if let urlString = track.previewUrl,
			let download = activeDownloads[urlString] {
			download.downloadTask?.cancel()
			activeDownloads[urlString] = nil
		}
	}
	
	func resumeDownload(track: Track) {
		if let urlString = track.previewUrl,
			let download = activeDownloads[urlString] {
			if let resumeData = download.resumeData {
				download.downloadTask = downloadsSession.downloadTaskWithResumeData(resumeData)
				download.downloadTask!.resume()
				download.isDownloading = true
			} else if let url = NSURL(string: download.url) {
				download.downloadTask = downloadsSession.downloadTaskWithURL(url)
				download.downloadTask!.resume()
				download.isDownloading = true
			}
		}
	}
	
	func startTimer(){
		runOnUIThread({
			var seconds = 1200
			if self.isSessiontaken == "true"{
				self.timerView.hidden = true
			}else{
				self.timerView.hidden = false
				if let data = self.sessionStatusData{
					
					if let _seconds = integerValueFromJSON(data, forKey: "ttl"){
						seconds = _seconds
					}
					self.timerObj = TeacherSessionCountDownTimer(view: self.timerView,label:self.timerLabel,seconds:seconds,delegate:self)
					
				}
			}
		})
	}
	
	func trackIndexForDownloadTask(downloadTask: NSURLSessionDownloadTask) -> Int? {
		if let url = downloadTask.originalRequest?.URL?.absoluteString {
			for (index, track) in searchResults.enumerate() {
				if url == track.previewUrl! {
					return index
				}
			}
		}
		return nil
	}
	
	
	//MARK: NSURLSESSION DELEGATE METHOD
	
	func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
		printDebug("in completion method call \(session)")
	}
	
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
		if let originalURL = downloadTask.originalRequest?.URL?.absoluteString,
			let _currentSessionId = self.currentSessionId,let destinationURL = TeacherCommonClass.localFilePathForUrl(originalURL,currentSessionId:_currentSessionId) {
			
			let fileManager = NSFileManager.defaultManager()
			printDebug("destinationURL \(destinationURL)")
			do {
				if fileManager.fileExistsAtPath("\(destinationURL)") {
					try fileManager.removeItemAtURL(destinationURL)
				}
			} catch {
				printDebug("catch in removing file \(error)")
			}
			do {
				try fileManager.copyItemAtURL(location, toURL: destinationURL)
				
			}catch{
				printDebug("Could not copy file to disk: \(error)")
			}
			runOnUIThread({
				self.tableView.reloadData()
			})
		}
	}
	
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		
		let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
		printDebug("progress \(progress)")
	}
	
	func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
		printDebug("didBecomeInvalidWithError \(error)")
	}
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		printDebug("didCompleteWithError \(error)")
	}
	
	
	
	//MARK: cellTappedHandler
	func pauseTapped(cell: TeacherAudioCell) {
		if let indexPath = tableView.indexPathForCell(cell) {
			let track = searchResults[indexPath.row]
			pauseDownload(track)
		}
	}
	
	func resumeTapped(cell: TeacherAudioCell) {
		if let indexPath = tableView.indexPathForCell(cell) {
			let track = searchResults[indexPath.row]
			resumeDownload(track)
			
		}
	}
	
	func cancelTapped(cell: TeacherAudioCell) {
		if let indexPath = tableView.indexPathForCell(cell) {
			let track = searchResults[indexPath.row]
			cancelDownload(track)
			dispatch_async(dispatch_get_main_queue(),{
				self.tableView.reloadData()
			})
		}
	}
	
	func downloadTapped(cell: TeacherAudioCell) {
		printDebug("downloadTapped cell \(cell)")
		
		if let indexPath = tableView.indexPathForCell(cell) {
			let track = searchResults[indexPath.row]
			printDebug("track \(track)")
			startDownload(track)
			
			dispatch_async(dispatch_get_main_queue(),{
				self.tableView.reloadData()
			})
			
		}
	}
	
	
	func uploadButtonTapped(cell: TeacherAudioCell){
		
		if let indexPath = tableView.indexPathForCell(cell){
			let track = searchResults[indexPath.row]
			if let urlString = track.previewUrl{
				
			let path = urlString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
				if let url = NSURL(string:path){
				printDebug("urlString \(urlString)")
				let myUrl = NSURL(string: "https://mail.culturealley.com/english-app/utility/uploadChatAudioFileOnGoogleCloud.php")
				
				//if let url = NSURL(string:urlString){
				self.currentAudioFileName = url
				currentAudioFileUploadStatus["\(url)"] = track.time
				
				self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
				
				let asset = AVURLAsset(URL: url , options: nil)
				let audioDuration = asset.duration
				printDebug("audioDuration \(audioDuration)")
				audioDurationSeconds = CMTimeGetSeconds(audioDuration)
				
				let request = NSMutableURLRequest(URL:myUrl!)
				request.HTTPMethod = "POST"
				request.setValue("multipart/form-data;boundary=*****", forHTTPHeaderField: "Content-Type")
				printDebug("url \(url)")
				let path =  url.path
				let audioData  = NSData(contentsOfFile: path!)
				
				printDebug("audioData \(audioData)")
//				do {
//					let str = try NSString(contentsOfFile: path!,
//					                       encoding: NSUTF8StringEncoding)
//					printDebug("str \(str)")
//				}
//				catch let error as NSError {
//					print("errror \(error.localizedDescription)")
//				}
				
//				let audioData2  = NSData(contentsOfURL: url)
//				
//				printDebug("audioData2  \(audioData2 )")
//				
				
				if let path =  url.path , let audioData  = NSData(contentsOfFile: path){
					
					printDebug("fileData \(audioData)")
					
					request.HTTPBody = createBodyWithParameters(audioData,audioDuration: audioDurationSeconds)
					let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
						data, response, error in
						if error != nil {
							print("error in uploading audio =\(error)")
							
							return
						}
						
						do{
							if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:NSObject]{
								self.updateAudioFileEntry(url,jsonData: json)
							}
						}catch{
							printDebug("error \(error)")
						}
					}
					task.resume()
				}else{
					printDebug("Upload Chat audio file Data found to be nil")
				}
				//}
			}
		}
		}
	}
	
	func playButtonTapped(cell: TeacherAudioCell){
		if let indexPath = tableView.indexPathForCell(cell) {
			if cell.playerStateImageView.image == playImageObject{
				
				let track = searchResults[indexPath.row]
				currentPlayingAudioFileTag = cell.playerStateImageView.tag
				if audioPlayer == nil{
					playAudio(track,index: indexPath.row)
				}else{
					audioPlayer = nil
					playTimer.invalidate()
					playAudio(track,index: indexPath.row)
				}
				
			}else if cell.playerStateImageView.image == pauseImageObject{
				currentPlayingAudioFileTag = nil
				playTimer.invalidate()
				audioPlayer = nil
				self.loadTableView()
			}
			
		}
	}
	
	func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
		printDebug(" error \(error)")
	}
	
	func audioPlayerEndInterruption(player: AVAudioPlayer, withOptions flags: Int) {
		printDebug("flags \(flags)")
	}
	
	func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
		
		currentPlayingAudioFileTag = nil
		audioPlayer = nil
		printDebug("successfully \(flag)")
		playTimer.invalidate()
		
		dispatch_async(dispatch_get_main_queue(),{
			self.tableView.reloadData()
		})
	}
	
	
	func updateSlider(){
		if let index = currentPlayingAudioFileTag,let teacherAudioCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? TeacherAudioCell {
			
			let value = Float(audioPlayer.currentTime/audioPlayer.duration)
			printDebug("audioPlayer.duration \(audioPlayer.duration) audioPlayer.currentTime \(audioPlayer.currentTime) ")
			teacherAudioCell.sliderProgressUpdater(value)
		}else{
			currentPlayingAudioFileTag = nil
			audioPlayer = nil
			playTimer.invalidate()
			dispatch_async(dispatch_get_main_queue(),{
				self.tableView.reloadData()
			})
		}
	}
	
	func playAudio(track: Track,index:Int){
		let serialQueue = dispatch_queue_create("com.helloEnglish.audioPlay",DISPATCH_QUEUE_SERIAL)
		
		dispatch_async(serialQueue,{() -> Void in
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
			})
			
		})
		dispatch_async(serialQueue) { () -> Void in
			
			if let urlString = track.previewUrl ,let _currentSessionId = self.currentSessionId,let url = TeacherCommonClass.localFilePathForUrl(urlString,currentSessionId:_currentSessionId){
				let asset = AVURLAsset(URL: url, options: nil)
				let audioDuration = asset.duration
				self.audioDurationSeconds = CMTimeGetSeconds(audioDuration)
				let soundData = NSData(contentsOfURL: url)
				do {
					self.audioPlayer = try AVAudioPlayer(data: soundData!)
					self.audioPlayer.prepareToPlay()
					self.audioPlayer.delegate = self
					self.audioPlayer.play()
					dispatch_async(dispatch_get_main_queue(), {
						self.playTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
					})
				}
				catch {
					print("Something bad happened. Try catching specific errors to narrow things down",error)
				}
				
			}
		}
		
	}
	
	
	func startRecording() {
		self.audioTimer = nil
		loadSoundRecordStart()
		if let audioPlayer = self.audioPlayer {
			audioPlayer.play()
		}
		if isAllowRecording{
			
			audioFileNameCounter += 1
			runOnUIThread({
				self.audioTimer = TeacherAudioRecordTimer(label: self.audioTimerLabel)
			})
			if let url = TeacherCommonClass.getDocumentsDirectory(self.currentSessionId){
				
				let dateFormatter = NSDateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
				let time = dateFormatter.stringFromDate(NSDate())
				
				let audioFilename = url.URLByAppendingPathComponent("\(time)"+".m4a")
				currentAudioFileName = audioFilename
				let settings = [
					AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
					AVSampleRateKey: 12000,
					AVNumberOfChannelsKey: 1,
					AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
				]
				
				do {
					audioRecorder = try AVAudioRecorder(URL: audioFilename!, settings: settings)
					audioRecorder.delegate = self
					audioRecorder.record()
				} catch {
					finishRecording(false)
				}
			}
		}else{
			Toast.makeToastWithText("Record permission is not enable", duration: .Small)
		}
	}
	
	
	func finishRecording(success: Bool) {
		isRecordingStart = false
		isRecordingCancelled = false
		
		if let recorder = audioRecorder where recorder.recording{
			audioRecorder.stop()
		}
		audioRecorder = nil
		audioTimer?.timer.invalidate()
		audioTimer = nil
		if success{
			createAudioFileEntryInDataBase()
		} else {
			printDebug("recording failed :(")
		}
	}
	
	func recordTapped() {
		if audioRecorder == nil {
			startRecording()
			
		} else {
			finishRecording(false)
		}
	}
	
	func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
		if !flag {
			finishRecording(false)
		}
	}
	
	func didUpdateChatMessages(notification: NSNotification) {
		let operation3 = NSBlockOperation(block: {
			self.loadPreviousChatData()
		})
		
		localQueue.addOperation(operation3)
	}
	
	func uploadAudioChatFileToServer(){
		let myUrl = NSURL(string: "https://mail.culturealley.com/english-app/utility/uploadChatAudioFileOnGoogleCloud.php")
		
		var fileData : NSData?
		if let url = currentAudioFileName{
			fileData  = NSData(contentsOfURL: url)
			let asset = AVURLAsset(URL: url , options: nil)
			let audioDuration = asset.duration
			audioDurationSeconds = CMTimeGetSeconds(audioDuration)
			if audioDurationSeconds == 0.0{
				return
			}
			let request = NSMutableURLRequest(URL:myUrl!)
			request.HTTPMethod = "POST"
			request.setValue("multipart/form-data;boundary=*****", forHTTPHeaderField: "Content-Type")
			let audioData = fileData
			request.HTTPBody = createBodyWithParameters(audioData!,audioDuration: audioDurationSeconds)
			let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
				data, response, error in
				
				if error != nil {
					print("ereror in uploading audio file=\(error)")
					return
				}
				
				do{
					if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:NSObject]{
						self.updateAudioFileEntry(url,jsonData: json)
						
					}
				}catch{
					printDebug("error \(error)")
				}
			}
			task.resume()
		}
		
	}
	
	func createBodyWithParameters(imageDataKey: NSData,audioDuration:Double) -> NSData {
		
		let body = NSMutableData()
		
		var emailId = ""
		var gcmId = ""
		var teacherId = ""
		var teacherEmail = ""
		let filename = "\(self.audioFileNameCounter)"
		let audioDurationSeconds = "\(audioDuration)"
		
		if let data = sessionStatusData{
			if let _data = data["teacher_id"] as? String{
				teacherId = _data
			}
			if let _data = data["teacher_email"] as? String{
				teacherEmail = _data
			}
			
		}
		if let _email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			emailId = _email
		}
		
		if let _gcm = Prefs.stringForKey(Prefs.KEY_GCM_REG_ID){
			gcmId = _gcm
		}
		
		body.appendString("--*****\r\n")
		
		body.appendString("Content-Disposition: form-data; name=\"uploadedFile\";filename=\"\(filename)\"\r\n")
		body.appendString("\r\n")
		body.appendData(imageDataKey)
		body.appendString("\r\n")
		body.appendString("--*****\r\n")
		
		body.appendString("Content-Disposition: form-data; name=\"userId\""+"\r\n")
		body.appendString("\r\n")
		body.appendString(emailId)
		body.appendString("\r\n")
		body.appendString("--*****\r\n")
		
		body.appendString("Content-Disposition: form-data; name=\"gcmId\""+"\r\n")
		body.appendString("\r\n")
		body.appendString(gcmId)
		body.appendString("\r\n")
		body.appendString("--*****\r\n")
		
		body.appendString("Content-Disposition: form-data; name=\"sessionId\""+"\r\n")
		body.appendString("\r\n")
		if let id = self.currentSessionId{
			body.appendString(id)
		}
		body.appendString("\r\n")
		body.appendString("--*****\r\n")
		
		body.appendString("Content-Disposition: form-data; name=\"duration\""+"\r\n")
		body.appendString("\r\n")
		body.appendString(audioDurationSeconds)
		body.appendString("\r\n")
		body.appendString("--*****\r\n")
		
		body.appendString("Content-Disposition: form-data; name=\"teacherId\""+"\r\n")
		body.appendString("\r\n")
		body.appendString(teacherId)
		body.appendString("\r\n")
		body.appendString("--*****\r\n")
		
		body.appendString("Content-Disposition: form-data; name=\"receiverEmail\""+"\r\n")
		body.appendString("\r\n")
		body.appendString(teacherEmail)
		body.appendString("\r\n")
		body.appendString("--*****\r\n")
		
		body.appendString("Content-Disposition: form-data; name=\"senderEmail\""+"\r\n")
		body.appendString("\r\n")
		body.appendString(emailId)
		body.appendString("\r\n")
		body.appendString("--*****\r\n")
		
		return body
	}
	
	
	func updateAudioFileEntry(currentAudioFileName: NSURL,jsonData: [String:NSObject]){
		
		var time = ""
		for (key,value) in currentAudioFileUploadStatus{
			if key == "\(currentAudioFileName)"{
				time = value
				currentAudioFileUploadStatus.removeValueForKey(key)
				break
			}
		}
		
		if let chatEntry = ChatTeacher.fetchSessionTime(inContext: self.context, time: time){
			
			if chatEntry.id == "temp" ,let id = integerValueFromJSON(jsonData, forKey: "success"){
				chatEntry.setValue("\(id)" , forKey: "id")
			}
			
			if let data = chatEntry.data as? String,let jsonArray = parseJSON(fromString: data) as? [String:NSObject],let url = jsonData["audioFile"] as? String{
				let updatedData = buildDataKeyForChat(jsonArray,url: url)
				chatEntry.setValue(updatedData , forKey: "data")
				let originalURL = url
				if let _currentSessionId = self.currentSessionId,let destinationURL = TeacherCommonClass.localFilePathForUrl(originalURL,currentSessionId:_currentSessionId) {
					
					let fileManager = NSFileManager.defaultManager()
					
					do {
						
						if let filePath = currentAudioFileName.path where NSFileManager.defaultManager().fileExistsAtPath("\(filePath)") {
							try fileManager.copyItemAtURL(currentAudioFileName , toURL: destinationURL)
							try fileManager.removeItemAtURL(currentAudioFileName)
							
						}
					} catch {
						printDebug("catch in removing file \(error)")
					}
				}else{
					printDebug(" some nil self.currentSessionId \(self.currentSessionId) URl*** \(TeacherCommonClass.localFilePathForUrl(originalURL,currentSessionId: self.currentSessionId!))")
				}
				context.performBlockAndWait({
					do{
						try  self.context.save()
						
					}catch{
						printDebug("unable to update session chat data \(error)")
					}
				})
				let operation3 = NSBlockOperation(block: {
					self.loadPreviousChatData()
					
				})
				localQueue.addOperation(operation3)
			}
		}else{
			printDebug("else condition met")
		}
		
	}
	
	func buildDataKeyForChat(json : [String:NSObject],url:String)->String{
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
		
		data["filePath"] = url
		
		let dataString = toString(fromJSON:data) ?? ""
		
		return dataString
	}
	
	
	func createAudioFileEntryInDataBase(){
		var teacherId = ""
		var teacherEmail = ""
		var sessionId = ""
		let operation1 = NSBlockOperation(block: {
		if let data = self.sessionStatusData,let url = self.currentAudioFileName{
			
			if let _data = data["teacher_id"] as? String{
				teacherId = _data
			}
			if let _data = data["teacher_email"] as? String{
				teacherEmail = _data
			}
			
			if let _data = data["session_id"] as? String{
				sessionId = _data
			}
			
			var jsonText = [String:NSObject]()
			jsonText["text"] = ""
			jsonText["type"] = "normal"
			let jsonTextString = toString(fromJSON:jsonText)
			
			var data = [String:NSObject]()
			
			data["duration"] = "\(self.audioDurationSeconds)"
			
			data["text"] = jsonTextString
			data["imagePath"] = ""
			if let filePath = self.currentAudioFileName {
				data["filePath"] = filePath.path
			}
			data["type"] = "audio"
			
//			let dateFormatter = NSDateFormatter()
//			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			
//			data["time"] = dateFormatter.stringFromDate(NSDate())
			
			
			let jsonDataString = toString(fromJSON:data)
			
			var userInfo = [NSObject:AnyObject]()
			userInfo["teacher_id"] = teacherId
			userInfo["from"] = ""
			userInfo["id"] = "temp"
			userInfo["session_id"] = sessionId
			userInfo["data"] = jsonDataString
			userInfo["teacher_email"] = teacherEmail
			userInfo["type"] = "chat_teacher_audio"
			userInfo["sub_type"] = "reply"
			
			if let lastPathComponent = url.lastPathComponent{
				let dummyTime = lastPathComponent.split(".")
				let time = dummyTime[0]
				userInfo["time"] = time
			}

			
			self.currentAudioFileUploadStatus["\(url)"] = userInfo["time"] as? String
				ChatTeacher.processTeacherMessage(userInfo,sender:senderType.SENDER_IS_USER.rawValue,isSingleEntry: true)
			
			
			
		}
			})
		
		let operation2 = NSBlockOperation(block: {
			self.uploadAudioChatFileToServer()
		})
		
		localQueue.addOperation(operation1)
		localQueue.addOperation(operation2)
		operation2.addDependency(operation1)
	}
	
	func loadSoundRecordStart() {
		do {
			let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("voice_note_start", ofType: "wav")!)
			self.audioPlayer = try AVAudioPlayer(contentsOfURL: url)
			self.audioPlayer.prepareToPlay()
		} catch{
			printDebug("Unable to load recording start sound: \(error)")
		}
	}
	
	func loadSoundRecordStop() {
		do {
			let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("voice_note_error", ofType: "wav")!)
			self.audioPlayer = try AVAudioPlayer(contentsOfURL: url)
			self.audioPlayer.prepareToPlay()
		} catch {
			printDebug("Unable to load recording start sound: \(error)")
		}
	}
	
	func timeString(time:NSTimeInterval) -> String {
		let minutes = Int(time) / 60 % 60
		let seconds = Int(time) % 60
		return String(format:"%02d : %02d", minutes, seconds)
	}
	
	//MARK: keyBoard related function
	func keyboardWillShow(notification:NSNotification) {
		let userInfo:NSDictionary = notification.userInfo!
		let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
		let keyboardRectangle = keyboardFrame.CGRectValue()
		let height = keyboardRectangle.height
		
		if self.textViewBottomConst.constant == 0{
			self.textViewBottomConst.constant += height
			self.view.layoutIfNeeded()
		}
		
	}
	
	func keyboardWillHide(notification:NSNotification) {
		let userInfo:NSDictionary = notification.userInfo!
		let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
		let keyboardRectangle = keyboardFrame.CGRectValue()
		let height = keyboardRectangle.height
		if self.textViewBottomConst.constant != 0{
			self.textViewBottomConst.constant -= height
			self.view.layoutIfNeeded()
		}
	}
	
	func hideKeyboard(){
		if textView.isFirstResponder(){
			self.textView.resignFirstResponder()
		}
	}
	
	
	// MARK: Touch related functions
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesBegan(touches, withEvent: event)
		
		if(touches.first?.view == sendMessageView) {
			if sendMessageImageView.image == textSendImageObject{
				var typedText = ""
				if let _text = textView.text{
					typedText = _text
				}
				if typedText != ""{
					self.textView.resignFirstResponder()
					
					self.messageSendingLoaderVIew.hidden = false
					self.addUserMessageView.hidden = true
					
					if let data = self.sessionStatusData{
						
						let status = TeacherServerMethodCalls.sendUserMessageToServer(data,typedText: typedText)
						if status{
							let operation2 = NSBlockOperation(block: {
								self.loadPreviousChatData()
								
								NSOperationQueue.mainQueue().addOperationWithBlock({
									self.messageSendingLoaderVIew.hidden = true
									self.addUserMessageView.hidden = false
									self.textView.text = ""
								})
							})
							
							self.localQueue.addOperation(operation2)
						}
						
					}
					
				}else{
					Toast.makeToastWithText("Please write some message", duration: .Small)
				}
				
			}else if sendMessageImageView.image == audioImageObject{
				self.textView.hidden = true
				self.audioRecordSliderView.hidden = false
				self.chatMessageImageView.hidden = true
				if !dimensionUpdated{
					dimensionUpdated = true
					self.sendMessageWidthConstraint.constant += 20
					self.sendMessageLeadingConstatint.constant -= 10
					
					if isPad(){
						self.sendMessageView.layer.cornerRadius = 70/2
					}else{
						self.sendMessageView.layer.cornerRadius = 60/2
					}
					
					centerConstraint = NSLayoutConstraint(item: sendMessageView, attribute: .CenterY, relatedBy: .Equal, toItem: sendMessageView.superview!, attribute: .CenterY, multiplier: 1, constant: 0)
					
					NSLayoutConstraint.activateConstraints([self.centerConstraint])
					NSLayoutConstraint.deactivateConstraints([self.sendMessageTopConstraint])
					self.sendMessageView.clipsToBounds = true
					self.sendMessageView.layoutIfNeeded()
				}
				isRecordingStart = true
				if isRecordingStart{
					startRecording()
				}
			}else{
				printDebug("anonymous condition met")
			}
		}else{
			if textView.isFirstResponder(){
				self.textView.resignFirstResponder()
			}
		}
	}
	
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesMoved(touches, withEvent: event)
		
		if sendMessageImageView.image == audioImageObject{
			if(touches.first?.view == sendMessageView) {
				let startPoint = touches.first?.locationInView(self.view)
				let x = startPoint!.x
				if self.view.frame.width - x - self.sendMessageView.frame.width > 10 {
					if x > (self.view.frame.width/2 - self.sendMessageView.frame.width/2) {
						self.isRecordingCancelled = true
						UIView.animateWithDuration(0.1, animations: {
							self.sendMessageTrailingConstraint.constant = self.view.frame.width - x - self.sendMessageView.frame.width
							
							self.sendMessageView.layoutIfNeeded()
							}, completion: { _ in
								self.dimensionUpdated = false
								self.finishRecording(false)
						})
					}
				}else{
					printDebug("Recording button moved")
					
				}
				
			}
		}
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)
		printDebug("touch  end event called")
		self.textView.hidden = false
		self.chatMessageImageView.hidden = false
		self.audioRecordSliderView.hidden = true
		
		if sendMessageImageView.image == audioImageObject{
			self.sendMessageTrailingConstraint.constant = 4
			dimensionUpdated = false
			NSLayoutConstraint.activateConstraints([self.sendMessageTopConstraint])
			if let constraint = self.centerConstraint{
			NSLayoutConstraint.deactivateConstraints([constraint])
			}
			if isPad(){
				
				if self.sendMessageWidthConstraint.constant != 50{
					self.sendMessageWidthConstraint.constant = 50
					self.sendMessageLeadingConstatint.constant = 15
					self.sendMessageView.layer.cornerRadius = 60/2
				}
			}else{
				if self.sendMessageWidthConstraint.constant != 40{
					self.sendMessageWidthConstraint.constant = 40
					self.sendMessageView.layer.cornerRadius = 40/2
					self.sendMessageLeadingConstatint.constant = 15
				}
			}
			
			
			UIView.animateWithDuration(0.2, animations: {
				self.sendMessageView.layoutIfNeeded()
				},completion: nil)
			
			if self.audioRecorder != nil{
				audioRecorder.stop()
				loadSoundRecordStop()
				if let audioPlayer = self.audioPlayer {
					audioPlayer.play()
				}
				
				//				if let url = TeacherCommonClass.getDocumentsDirectory(self.currentSessionId){
				//
				//					let dateFormatter = NSDateFormatter()
				//					dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
				//					let time = dateFormatter.stringFromDate(NSDate())
				//
				//let audioFilename = currentAudioFileName
				//printDebug("audioFilename  \(audioFilename)")
				//					let asset = AVURLAsset(URL: audioFilename! , options: nil)
				//					let audioDuration = asset.duration
				//***
				
				var fileData : NSData?
				if let url = currentAudioFileName{
					fileData  = NSData(contentsOfURL: url)
					printDebug("fileData \(fileData)")
					let asset = AVURLAsset(URL: url , options: nil)
					let audioDuration = asset.duration
					audioDurationSeconds = CMTimeGetSeconds(audioDuration)
					printDebug("audioDurationSeconds \(audioDurationSeconds) audioDuration \(audioDuration)")
					//***
					//audioDurationSeconds = CMTimeGetSeconds(audioDuration)
					if audioDurationSeconds > 0{
						if !isRecordingCancelled{
							finishRecording(true)
						}
					}else{
						printDebug("audioDurationSeconds \(audioDurationSeconds)")
						finishRecording(false)
					}
				}
				//}
			}
			if isRecordingCancelled{
				finishRecording(false)
			}
		}
	}
	
	
	override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesCancelled(touches, withEvent: event)
		printDebug("touch cancell event called")
		self.textView.hidden = false
		self.chatMessageImageView.hidden = false
		self.audioRecordSliderView.hidden = true
		
		if sendMessageImageView.image == audioImageObject{
			self.sendMessageTrailingConstraint.constant = 4
			dimensionUpdated = false
			NSLayoutConstraint.activateConstraints([self.sendMessageTopConstraint])
			if let constraint = self.centerConstraint{
				NSLayoutConstraint.deactivateConstraints([constraint])
			}
			if isPad(){
				
				if self.sendMessageWidthConstraint.constant != 50{
					self.sendMessageWidthConstraint.constant = 50
					self.sendMessageLeadingConstatint.constant = 15
					self.sendMessageView.layer.cornerRadius = 60/2
					
				}
			}else{
				if self.sendMessageWidthConstraint.constant != 40{
					self.sendMessageWidthConstraint.constant = 40
					self.sendMessageLeadingConstatint.constant = 15
					self.sendMessageView.layer.cornerRadius = 40/2
				}
			}
			
			
			UIView.animateWithDuration(0.2, animations: {
				self.sendMessageView.layoutIfNeeded()
				},completion: nil)
			
			if self.audioRecorder != nil{
				audioRecorder.stop()
				loadSoundRecordStop()
				if let audioPlayer = self.audioPlayer {
					audioPlayer.play()
				}
				finishRecording(false)
			}
		}
		
	}
	
	
	
	//MARK:Textview delegate method
	func textViewDidBeginEditing(textView: UITextView) {
		self.sendMessageImageView.image = textSendImageObject
		if textView.textColor == UIColor.lightGrayColor(){
			textView.text = nil
			textView.textColor = UIColor.blueColorCA()
		}
	}
	
	func textViewDidEndEditing(textView: UITextView) {
		self.sendMessageImageView.image = audioImageObject
		if textView.text.isEmpty {
			textView.text = "Type a message"
			textView.textColor = UIColor.lightGrayColor()
		}
	}
	
	func sessionFinish(){
		//Test
			isSessionFinish = true
			blockMessageSendView.hidden = true
			blockMessageLabel.hidden = true
			blockMessageSendView.hidden = false
			blockMessageLabel.hidden = false
	}
	private var counter = 0
	private var totalCount = 0
	private var allowToCallnotification = false
	
	func getTotalCount(totalCount : Int){
		printDebug("in session totalCount \(totalCount)")
		self.totalCount = totalCount
		if self.totalCount == 0{
			self.chatDataFetchedComplete(true)
		}else{
		   allowToCallnotification = true
		}
	}
	
	func lastEntryUpdation(notification: NSNotification) {
		if self.allowToCallnotification{
			
			self.counter += 1
			printDebug("totalCount \(totalCount) *** counter\(counter)")
			
			if self.totalCount == self.counter {
				self.allowToCallnotification = false
				self.chatDataFetchedComplete(true)
			}
		}
	}
	
}
