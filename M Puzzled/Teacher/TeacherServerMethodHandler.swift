//
//  TeacherServerMethodHandler.swift
//  Hello English
//
//  Created by Manisha on 30/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
import CoreData
import FirebaseAuth
import Firebase

final class TeacherServerMethodCalls: NSObject{
	
	class func getSessionStatusFromServer()-> Bool{
		var status = false
		
		printDebug("gcm \(Prefs.stringForKey(Prefs.KEY_GCM_REG_ID)) email \(Prefs.stringForKey(Prefs.KEY_USER_EMAIL))")
		let gcm = Prefs.stringForKey(Prefs.KEY_GCM_REG_ID)
		if gcm == nil{
			if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate{
			delegate.connectToFCM()
			}
			//TeacherServerMethodCalls.connectFCM()
		}else if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL),let gcm = Prefs.stringForKey(Prefs.KEY_GCM_REG_ID){
			var params = [RequestParam(key: "teacher", value: "true")]
			params.append(RequestParam(key: "email", value: email))
			params.append(RequestParam(key: "gcmId", value: gcm))
			
			do{
				let response = try ServerInterface.callSync(PHPAction.GET_ACTIVE_SESSION_IF_ANY, params: params, jsonType: .JSONObject)
				
				if let data = response.jsonObject?["success"] as? [String:NSObject]{
					
					let string = toString(fromJSON:data)
					
					if ((Prefs.objectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA) as? String) != nil){
						Prefs.removeObjectForKey(Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA)
						Prefs.setObject(string, forKey: Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA)
					}else{
						Prefs.setObject(string, forKey: Prefs.KEY_TEACHER_CHAT_SESSION_STATIC_DATA)
					}
					
					let defaults = NSUserDefaults(suiteName: "HelloEnglish")
					
					if let status = boolValueFromJSON(data, forKey: "session_active") where status == true {
						defaults?.setBool(true, forKey: Prefs.KEY_IS_TEACHER_CHAT_SESSION_STARTED)
					}else{
						defaults?.setBool(false, forKey: Prefs.KEY_IS_TEACHER_CHAT_SESSION_STARTED)
					}
					status = true
				}
			}catch{
				
				printDebug("In catch getSessionStatusFromServer \(error)")
			}
		}
		return status
	}
	
	class func connectFCM(){
		FIRMessaging.messaging().connectWithCompletion { (error) in
			if (error != nil) {
				printDebug("Unable to connect with FCM. \(error)")
			} else {
				printDebug("Connected to FCM.")
				if let token = FIRInstanceID.instanceID().token() {
					printDebug("InstanceID token: \(token)")
					if let gcm = Prefs.stringForKey(Prefs.KEY_GCM_REG_ID) {
						if gcm != token {
							Prefs.setObject(gcm, forKey: Prefs.KEY_OLD_GCM_REG_ID)
							Prefs.setObject(token, forKey: Prefs.KEY_GCM_REG_ID)
							
							printDebug("InstanceID token: \(token)")
							HomeController.startOperation(FCMRegistrationUpdater())
						}
					} else {
						Prefs.setObject(token, forKey: Prefs.KEY_GCM_REG_ID)
						
						printDebug("InstanceID token: \(token)")
						
						HomeController.startOperation(FCMRegistrationUpdater())
					}
					
				} else {
					printDebug("Invalid token")
				}
			}
			TeacherServerMethodCalls.getSessionStatusFromServer()
		}
	}
	
	class func getSessionHistory()-> [[String:NSObject]]?{
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			var params = [RequestParam(key: "teacher", value: "true")]
			params.append(RequestParam(key: "email", value: email))
			
			do{
				let response = try ServerInterface.callSync(PHPAction.GET_USER_SESSION_HISTORY, params: params, jsonType: .JSONObject)
				
				if let data = response.jsonObject?["success"] as? [[String:NSObject]]{
					
					return data
					
				}
			}catch{
				
				printDebug("In catch getSessionStatusFromServer \(error)")
			}
		}
		return nil
	}
	
	class func fetchSessionTimeFromServer()->[[String : NSObject]]?{
		let params = [RequestParam(key: "teacher", value: "true")]
		do{
			let response = try ServerInterface.callSync(PHPAction.GET_SESSION_TIME_SLOTS, params: params, jsonType: .JSONObject)
			
			if let sessionList = response.jsonObject?["success"] as? [[String : NSObject]] {
				printDebug("sessionList \(response)")
				return sessionList
			}
		}
		catch{
			printDebug("error fetchSessionTimeFromServer \(error)")
		}
		return nil
	}
	
	
	class func fetchBaseCreditFromServer()->Int?{
		let params = [RequestParam(key: "teacher", value: "true")]
		do{
			let response = try ServerInterface.callSync(PHPAction.GET_BASE_CREDIT, params: params, jsonType: .JSONObject)
			
			if let data = response.jsonObject?["success"] as? Int{
				return data
			}
		}catch{
			printDebug(" fetchBaseCreditFromServer() error \(error)")
		}
		return nil
	}
	
	class func fetchStaticData()->[String:NSObject]?{
		let params = [RequestParam(key: "teacher", value: "true")]
		do{
			let response = try ServerInterface.callSync(PHPAction.GET_TEACHER_STATIC_DATA, params: params, jsonType: .JSONObject)
			
			if let sessionList = response.jsonObject?["success"] as? [String : NSObject] {
				printDebug("sessionList \(response)")
				
				return sessionList
			}
		}
		catch{
			printDebug("error fetchStaticData() \(error)")
		}
		return nil
	}
	
	class func fetchUserCreditBalance()-> JSONObject?{
		
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			var params = [RequestParam(key: "teacher", value: "true")]
			params.append(RequestParam(key: "email", value: email))
			do{
				let response = try ServerInterface.callSync(PHPAction.USER_CREDIT_BALANCE, params: params, jsonType: .JSONObject)
				
				if let data = response.jsonObject?["success"] as? JSONObject{
					return data
				}
			}
			catch{
				runOnUIThread({
					Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
				})
				printDebug("error in fetchUserCreditBalance \(error)")
			}
		}
		return nil
	}
	
	class func sendUserMessageToServer(sessionStatusData : [String:NSObject],typedText : String)->Bool{
		var teacherId:String?
		var teacherEmail:String?
		var sessionId:String?
		
		if let _data = sessionStatusData["teacher_id"] as? String{
			teacherId = _data
		}
		if let _data = sessionStatusData["teacher_email"] as? String{
			teacherEmail = _data
		}
		if let _data = sessionStatusData["session_id"] as? String{
			sessionId = _data
		}
		
		if let _teacherId = teacherId,let teacherMail = teacherEmail ,let sessionId = sessionId ,let senderEmail = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			var params = [RequestParam(key: "teacher", value: "true")]
			params.append(RequestParam(key: "teacherId", value: _teacherId))
			params.append(RequestParam(key: "sessionId", value:sessionId))
			params.append(RequestParam(key: "receiverEmail", value: teacherMail))
			params.append(RequestParam(key: "text", value: typedText))
			params.append(RequestParam(key: "senderEmail", value: senderEmail))
			params.append(RequestParam(key: "name", value: "true"))
			
			do{
				let response = try ServerInterface.callSync(PHPAction.SAVE_NEW_CHAT_MESSAGE, params: params, jsonType: .JSONObject)
				
				if let id = response.jsonObject?["success"] as? Int{
					
					//					var jsonText = [String:NSObject]()
					//					jsonText["text"] = typedText
					//					jsonText["type"] = "normal"
					//					let jsonTextString = toString(fromJSON:jsonText)
					//
					var data = [String:NSObject]()
					data["duration"] = "0"
					//data["text"] = jsonTextString
					data["text"] = typedText
					data["type"] = "text"
					
					let jsonDataString = toString(fromJSON:data)
					
					printDebug("sessionList \(response)")
					var userInfo = [NSObject:AnyObject]()
					userInfo["teacher_id"] = teacherId
					userInfo["from"] = ""
					userInfo["id"] = "\(id)"
					userInfo["session_id"] = sessionId
					userInfo["data"] = jsonDataString
					printDebug("text data \(data)")
					userInfo["teacher_email"] = teacherMail
					userInfo["type"] = "chat_teacher_audio"
					userInfo["sub_type"] = "reply"
					printDebug("session userInfo \(userInfo)")
					//let userInfoString = toString(fromJSON:userInfo)
					ChatTeacher.processTeacherMessage(userInfo,sender:"0",isSingleEntry: true)
					//loadChatData()
					return true
				}
			}catch{
				runOnUIThread({
					Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
				})
				printDebug("error in sending text chat data \(error)")
			}
		}
		return false
		
	}
	
	
	class func updateSessionRating(sessionStatusData : [String:NSObject]){
		printDebug("sessionStatusData \(sessionStatusData)")
		var rating:String?
		var comment:String?
		var sessionId:String?
		
		var userEmail:String?
		
		if let _data = sessionStatusData["rating"] as? String{
			rating = _data
		}else{
			rating = ""
		}
		if let _data = sessionStatusData["comment"] as? String{
			comment = _data
		}else{
			comment = ""
		}
		if let _data = sessionStatusData["sessionId"] as? String{
			sessionId = _data
		}
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			userEmail = email
		}
		printDebug(" userEmail \(userEmail) _rating \(rating)  _sessionId \(sessionId) _comment \(comment)")
		
		if let _userEmail = userEmail,let _rating = rating ,let _sessionId = sessionId,let _comment = comment{
			var params = [RequestParam(key: "teacher", value: "true")]
			params.append(RequestParam(key: "email", value: _userEmail))
			params.append(RequestParam(key: "rating", value:_rating))
			params.append(RequestParam(key: "sessionId", value: _sessionId))
			params.append(RequestParam(key: "comment", value: _comment))
			
			do{
				let _ = try ServerInterface.callSync(PHPAction.UPDATE_SESSION_RATING, params: params, jsonType: .JSONObject)
				
			}catch{
				runOnUIThread({
					Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
				})
				printDebug("error in sending text chat data \(error)")
			}
		}
	}
	
	
}
