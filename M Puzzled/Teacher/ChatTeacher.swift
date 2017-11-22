//
//  ChatTeacher.swift
//  Hello English
//
//  Created by Manisha on 24/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let TeacherMessagesDidUpdateNotification = "com.CultureAlley.notif.TeacherMessagesDidUpdateNotification"
let TeacherEntryInsertionNotification = "com.CultureAlley.notif.TeacherEntryInsertionNotification"

enum senderType:String{
	case SENDER_IS_TEACHER = "1"
	case SENDER_IS_USER = "0"
}
class ChatTeacher:NSManagedObject{
	
	convenience init?(userInfo: [NSObject : AnyObject],sender:String ,inContext context: NSManagedObjectContext) {
		var id,session_id,status,teacher_id,teacher_email:String?
		var data = ""
		
		var time:String?
		if let _teacherId = userInfo["teacher_id"] as? String{
			teacher_id = _teacherId
		}
		if let _id = userInfo["id"] as? String{
			id = _id
		}
		if let _session_id = userInfo["session_id"] as? String{
			session_id = _session_id
		}
		
		
		if let _data = userInfo["data"] as? String{
			data = _data
		}
		
		if let _data = userInfo["time"] as? String{
			time = _data
		}
		
		if let _email = userInfo["teacher_email"] as? String{
			teacher_email = _email
		}
		
		if let entity = NSEntityDescription.entityForName("ChatTeacher", inManagedObjectContext: context) {
			self.init(entity: entity, insertIntoManagedObjectContext: context)
			self.id = id
			self.data = data
			self.sessionId = session_id
			self.status = status
			self.teacher_email = teacher_email
			self.teacher_id = teacher_id
			if let _time = time where _time != ""{
				self.time = _time
				
			}else{
				let  dateFormator = NSDateFormatter()
				dateFormator.dateFormat = "yyyy-MM-dd HH:mm:ss"
				dateFormator.timeZone = NSTimeZone.localTimeZone()
				
				self.time =  dateFormator.stringFromDate(NSDate())
			}
			printDebug("self.time \(self.time)")
			self.sender = sender
		} else {
			return nil
		}
	}
	
	class func doesMessageExistWithId(id: String, inContext context: NSManagedObjectContext) -> Bool {
		let request = NSFetchRequest(entityName: ChatTeacher.nameOfClass)
		request.predicate = NSPredicate(format: "id == %@", id)
		
		do {
			return try context.countForFetchRequest(request) > 0 ? true : false
		} catch {
			printDebug("doesExist.error: \(error)")
			
		}
		return false
	}
	
	
	private static let queue = NSOperationQueue()
	private class ChatTeacherMessageHandler: NSOperation {
		
		private let userInfo: [NSObject: AnyObject]
		private let sender:String
		private var isSingleEntry = true
		private var context:NSManagedObjectContext!
		
		init(userInfo: [NSObject: AnyObject],sender:String,isSingleEntry:Bool,context:NSManagedObjectContext?) {
			self.userInfo = userInfo
			self.sender = sender
			self.isSingleEntry = isSingleEntry
			self.context = context
		}
		
		override func main() {
			let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
			if context == nil{
				context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
				context.parentContext = delegate.managedObjectContext
			}
			
			//MARK: "temp keyword is used to distinguish audio entries which are not synced with server,but have to insert locally in database"
			if let id = userInfo["id"] as? String {
				
				var doesExist = false
				context.performBlockAndWait({
					doesExist = ChatTeacher.doesMessageExistWithId(id, inContext: self.context)
				})
				printDebug("id \(id) doesExist \(doesExist)")
				if doesExist && id != "temp" && id != "tempSession"{
					let notifCenter = NSNotificationCenter.defaultCenter()
					notifCenter.postNotificationName(TeacherEntryInsertionNotification, object: nil)
					return
				}
				
			} else {
				let notifCenter = NSNotificationCenter.defaultCenter()
				notifCenter.postNotificationName(TeacherEntryInsertionNotification, object: nil)
				return
			}
			
			context.performBlockAndWait({
				
				let message: ChatTeacher
				if let _message = ChatTeacher(userInfo: self.userInfo,sender:self.sender, inContext: self.context) {
					message = _message
					printDebug("message  ID\(message.id)")
				} else {
					let notifCenter = NSNotificationCenter.defaultCenter()
					notifCenter.postNotificationName(TeacherEntryInsertionNotification, object: nil)
					return
				}
				do {
					try self.context.save()
					printDebug("saving mainContext for teacher")
					self.context.parentContext?.performBlockAndWait({
						do {
							printDebug("saving parentContext for teacher")
							try self.context.parentContext?.save()
							if self.isSingleEntry{
								let notifCenter = NSNotificationCenter.defaultCenter()
								notifCenter.postNotificationName(TeacherMessagesDidUpdateNotification, object: nil)
							}
							NSNotificationCenter.defaultCenter().postNotificationName(TeacherEntryInsertionNotification, object: nil)
							
						} catch {
							printDebug("Unable to save teacher chat message (ParentContext): \(message), \(error)")
						}
					})
					
				} catch {
					printDebug("Unable to save chat message (LocalContext): \(message), \(error)")
				}
			})
			
		}
	}
	
	class func processTeacherMessage(userInfo: [NSObject : AnyObject],sender:String,isSingleEntry:Bool,context:NSManagedObjectContext? = nil){
		ChatTeacher.queue.maxConcurrentOperationCount = 1
		let msgHandler = ChatTeacherMessageHandler(userInfo: userInfo,sender: sender,isSingleEntry:isSingleEntry,context:context)
		ChatTeacher.queue.addOperation(msgHandler)
		
	}
	
	class func fetchSessionTime(inContext context: NSManagedObjectContext , time: String)->ChatTeacher?{
		let request = NSFetchRequest(entityName: ChatTeacher.nameOfClass)
		request.predicate = NSPredicate(format: "time = %@",time)
		var chatTeacher:ChatTeacher?
		do{
			if let data = ((try context.executeFetchRequest(request) as? [ChatTeacher]))?.first {
				chatTeacher = data
			}
		}catch{
			printDebug("error in fetching time teacher message")
		}
		return chatTeacher
	}
	
	class func getSessionCount(inContext context: NSManagedObjectContext)->Int?{
		let request = NSFetchRequest(entityName: ChatTeacher.nameOfClass)
		request.resultType = .DictionaryResultType
		
		request.propertiesToFetch = ["sessionId"]
		request.propertiesToGroupBy = ["sessionId"]
		var count:Int?
		context.performBlockAndWait({
			do{
				
				if let sessionIDs = try context.executeFetchRequest(request) as? [[String: String]]{
					count = sessionIDs.count
				}
				
			}catch{
				printDebug("unable to fetch teacher session count")
			}
			
		})
		return  count
	}
	
	class func removeSessionData(sessionID :String,inContext context: NSManagedObjectContext){
		
		let request = NSFetchRequest()
		request.entity = NSEntityDescription.entityForName(ChatTeacher.nameOfClass, inManagedObjectContext: context)
		request.predicate = NSPredicate(format: "sessionId = %@", sessionID)
		
		do {
			
			if let entities = (try? context.executeFetchRequest(request)) as? [ChatTeacher]
				where entities.count > 0 {
				for entity in entities {
					context.deleteObject(entity)
				}
				try context.save()
			}
		}catch{
			printDebug("unable to delete session chat data \(error)")
			
		}
		
		
	}
	class func doesMessageExistWithTime(inContext context: NSManagedObjectContext , time: String)->Bool{
		let request = NSFetchRequest(entityName: ChatTeacher.nameOfClass)
		request.predicate = NSPredicate(format: "time = %@",time)
		var status = false
		do{
			status  = try context.countForFetchRequest(request) > 0 ? true : false
			
		}catch{
			printDebug("error in fetching time teacher message")
		}
		return status
	}
	
	
	
	
	class func fetchSessionList(inContext context: NSManagedObjectContext)->[[String: [ChatTeacher]]]?{
		let request = NSFetchRequest(entityName: ChatTeacher.nameOfClass)
		var data = [String: [ChatTeacher]]()
		var dataList = [[String: [ChatTeacher]]]()
		request.resultType = .DictionaryResultType
		
		request.propertiesToFetch = ["sessionId"]
		request.propertiesToGroupBy = ["sessionId"]
		context.performBlockAndWait({
			do{
				
				if let sessionIDs = try context.executeFetchRequest(request) as? [[String: String]]{
					for sessionID in sessionIDs{
						guard let sessionIDName = sessionID["sessionId"] else {
							continue
						}
						
						let request = NSFetchRequest()
						request.entity = NSEntityDescription.entityForName(ChatTeacher.nameOfClass, inManagedObjectContext: context)
						request.predicate = NSPredicate(format: "sessionId = %@", sessionIDName)
						request.sortDescriptors = [NSSortDescriptor(key: "sessionId", ascending: false)]
						
						if let sessionIdData = (try? context.executeFetchRequest(request)) as? [ChatTeacher] {
							data["sessionData"] = sessionIdData
							dataList.append(data)
							printDebug("dataList \(dataList.count)")
							printDebug("data[sessionId] \(data["sessionData"])")
						}
					}
				}
				
			}catch{
				printDebug("Error in fetching session data")
			}
			
		})
		printDebug("data \(data)")
		return dataList
	}
	
	
	
}
