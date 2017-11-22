//
//  TeacherSessionChatBuilder.swift
//  Hello English
//
//  Created by Manisha on 03/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
import CoreData

protocol TeacherChatDelegate {
	func chatDataFetchedComplete(success:Bool)
	func getTotalCount(totalCount : Int)
}

class TeacherSessionChatBuilder:NSOperation{
	
	private var needToRefetch: Bool = false
	private let gcmId:String?
	private let teacherId:String?
	private let sessionId :String?
	private let email:String?
	private var delegate: TeacherChatDelegate!
	private var counter = 0
	private var totalCount = 0
	private var context:NSManagedObjectContext!
	
	init(delegate: TeacherChatDelegate,teacherId: String,sessionId:String,email:String,gcmId:String,context:NSManagedObjectContext) {
		self.delegate = delegate
		self.teacherId = teacherId
		self.sessionId = sessionId
		self.email = email
		self.gcmId = gcmId
		self.context = context
	}
	
	override func main() {
		
//		NSNotificationCenter.defaultCenter().addObserver(self,
//		                                                 selector: #selector(self.lastEntryUpdation(_:)),
//		                                                 name: TeacherEntryInsertionNotification,
//		                                                 object: nil)
		self.fetchData()
		
	}
	
	private func fetchData() {
		printDebug("emailID \(self.email)")
		var params = [RequestParam]()
		if let _email = self.email,let _gcmId = self.gcmId,let _teacherId = self.teacherId,let _sessionId = self.sessionId{
			params.append(RequestParam(key: "teacher", value: "true"))
			params.append(RequestParam(key: "teacherId", value: "\(_teacherId)"))
			params.append(RequestParam(key: "sessionId", value: "\(_sessionId)"))
			params.append(RequestParam(key: "email", value: "\(_email)"))
			params.append(RequestParam(key: "gcmId", value: "\(_gcmId)"))
			
			do {
				let response = try ServerInterface.callSync(.GET_USER_CHAT_HISTORY, params: params, jsonType: .JSONObject)
				if let success = response.jsonObject?["success"] as? [[String: NSObject]]{
					
					totalCount = success.count
					printDebug("totalCount \(totalCount)")
					
					self.delegate?.getTotalCount(totalCount)
					
					for data in success{
						constructJson(data)
					}
					
				}
			} catch {
				printDebug("Error in fetching profile Detail: \(error)")
				self.delegate?.chatDataFetchedComplete(false)
			}
		}
	}
	
	
	private func constructJson(json:[String:NSObject]){
		
		var sender = ""
		var userInfo = [NSObject:AnyObject]()
		
		userInfo["teacher_id"] = self.teacherId
		userInfo["from"] = ""
		
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
				userInfo["teacher_email"] = receiverEmail
				sender = senderType.SENDER_IS_USER.rawValue
			}else{
				return
			}
			
		}else{
			return
		}
		userInfo["type"] = "chat_teacher_audio"
		userInfo["sub_type"] = "reply"
		ChatTeacher.processTeacherMessage(userInfo,sender:sender,isSingleEntry: false,context: self.context)
	}
	
//	func lastEntryUpdation(notification: NSNotification) {
//		self.counter += 1
//		printDebug("totalCount \(totalCount) *** counter\(counter)")
//		
//		if self.totalCount-1 == self.counter{
//			self.delegate?.chatDataFetchedComplete(true)
//		}
//    }
	
}
