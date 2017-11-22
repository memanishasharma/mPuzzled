	//
//  TeacherCommonClass.swift
//  Hello English
//
//  Created by Manisha on 06/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//
import Foundation
import SystemConfiguration

class TeacherCommonClass:NSObject{
	
	class func getHoursAndMinute(startTime:String,endTime:String)->String?{
		printDebug("NstartTime \(startTime) endTime \(endTime)")
		let dateFormator = NSDateFormatter()
		dateFormator.dateFormat = "yyyy-MM-dd HH:mm:ss"
		dateFormator.timeZone = NSTimeZone.localTimeZone()
		
		if let date = dateFormator.dateFromString(startTime){
			let calendar = NSCalendar.currentCalendar()
			let comp = calendar.components([.Hour, .Minute], fromDate: date)
			let hour = comp.hour
			var minute = "\(comp.minute)"
			if minute.characters.count == 1{
				minute = "0" + minute
			}else if  minute.characters.count == 0{
				minute = "00"
			}
			let startHour = "\(hour):\(minute)"
			
			let date2 = dateFormator.dateFromString(endTime	)
			
			let calendar2 = NSCalendar.currentCalendar()
			let comp2 = calendar2.components([.Hour, .Minute], fromDate: date2!)
			let hour2 = comp2.hour
			//let minute2 = comp2.minute
			var minute2 = "\(comp2.minute)"
			if minute2.characters.count == 1{
				minute2 = "0" + minute2
			}else if  minute2.characters.count == 0{
				minute2 = "00"
			}
			
			let endHour = "\(hour2):\(minute2)"
			let slotTime = "\(startHour) - \(endHour)"
			
			return slotTime
		}
		return nil
		
	}
	
	
	class func getLocalTimeString(date:String)->String?{
		printDebug("sent Date \(date)")
		let dateFormator = NSDateFormatter()
		dateFormator.dateFormat = "yyyy-MM-dd HH:mm:ss"
		dateFormator.timeZone = NSTimeZone(name: "GMT")
		
		let localDate = dateFormator.dateFromString(date)
		dateFormator.timeZone = NSTimeZone.localTimeZone()
		dateFormator.dateFormat = "yyyy-MM-dd HH:mm:ss"
		if let date = localDate{
		let strDate = dateFormator.stringFromDate(date)
			printDebug("localDate \(strDate))")
			return strDate
		}
		return nil
	}
	
	class func getLocalTimeFormattedString(date:String)->String?{
		printDebug("sent Date \(date)")
		let dateFormator = NSDateFormatter()
		dateFormator.dateFormat = "yyyy-MM-dd HH:mm:ss"
		dateFormator.timeZone = NSTimeZone(name: "GMT")
		
		let localDate = dateFormator.dateFromString(date)
		dateFormator.timeZone = NSTimeZone.localTimeZone()
		dateFormator.dateFormat = "MMM dd, yyyy"
		if let date = localDate{
			let strDate = dateFormator.stringFromDate(date)
			printDebug("localDate \(strDate))")
			
			return strDate
		}
		return nil
	}
	
	class func getImage(url: NSURL) -> UIImage? {
		
		var image : UIImage?
		
		if let path = url.path {
			if NSFileManager.defaultManager().fileExistsAtPath(path) {
				if let newImage = UIImage(contentsOfFile: path)  {
					image = newImage
				} else {
					print("getImage() [Warning: file exists at \(path) :: Unable to create image]")
				}
				
			} else {
				print("getImage() [Warning: file does not exist at \(path)]")
			}
		}
		
		return image
	}
	
	
	
	class func getDate(startTime : String)-> String?{
		let dateFormator = NSDateFormatter()
		dateFormator.dateFormat = "yyyy-MM-dd HH:mm:ss"
		dateFormator.timeZone = NSTimeZone.localTimeZone()
		
		if let date = dateFormator.dateFromString(startTime){
			let calendar = NSCalendar.currentCalendar()
			printDebug("date \(date)")
			let comp = calendar.components([.Day,.Weekday,.Month,.Year,.Calendar], fromDate: date)
			
			let months = ["Jan","Feb","March","April","May","June","July","Aug","Sept","Oct","Nov","Dec"]
			let days = ["Sun","Mon","Tue","Wed","Thur","Fri","Sat"]
			
			
			let date = "\(days[comp.weekday-1])," + " \(comp.day)th" + "\(months[comp.month-1])" + "\(comp.year)"
			 return date
		}
		return nil
	}
	
	
	class func getTimeDiffAndYYYYMMDD(startTime:String,endTime:String)-> String?{
		printDebug("NstartTime \(startTime) endTime \(endTime)")
		let dateFormator = NSDateFormatter()
		dateFormator.dateFormat = "yyyy-MM-dd HH:mm:ss"
		dateFormator.timeZone = NSTimeZone.localTimeZone()
		
		if let date = dateFormator.dateFromString(startTime){
			let calendar = NSCalendar.currentCalendar()
			let comp = calendar.components([.Hour, .Minute], fromDate: date)
			let hour = comp.hour
			var minute = "\(comp.minute)"
			if minute.characters.count == 1{
				minute = "0" + minute
			}else if  minute.characters.count == 0{
				minute = "00"
			}
			let startHour = "\(hour):\(minute)"
			
			let date2 = dateFormator.dateFromString(endTime	)
			
			let calendar2 = NSCalendar.currentCalendar()
			let comp2 = calendar2.components([.Hour, .Minute], fromDate: date2!)
			let hour2 = comp2.hour
			//let minute2 = comp2.minute
			var minute2 = "\(comp2.minute)"
			if minute2.characters.count == 1{
				minute2 = "0" + minute2
			}else if  minute2.characters.count == 0{
				minute2 = "00"
			}
			
			let endHour = "\(hour2):\(minute2)"
			let slotTime = "\(startHour) - \(endHour)"
			
			
			if let dateObject = dateFormator.dateFromString(startTime) {
				//dateFormator.dateFormat = "MMM dd, yyyy"
				dateFormator.dateFormat = "yyyy-MM-dd"
				let dateString = dateFormator.stringFromDate(dateObject)
				printDebug("ateString \(dateString)")
				let time = slotTime + "(\(dateString))"
				return time
			}
			
			return slotTime
		}
		return nil
		
	}
	
	class func isConnectedToNetwork() -> Bool {
		
		var zeroAddress = sockaddr_in()
		zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)
		let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
			SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
		}
		var flags = SCNetworkReachabilityFlags()
		if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
			return false
		}
		let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
		let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
		printDebug("status net conection \(isReachable && !needsConnection)")
		return (isReachable && !needsConnection)
		
	}

	
	class func localFileExistsForTrack(track: Track,currentSessionId: String?) -> Bool {
		if let urlString = track.previewUrl,let _currentSessionId = currentSessionId,let localUrl = localFilePathForUrl(urlString,currentSessionId: _currentSessionId) {
			var isDir : ObjCBool = false
			printDebug("localUrl \(localUrl)")
			if let path = localUrl.path {
				return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
			}
		}
		return false
	}

	class func getDocumentsDirectory(currentSessionId:String?) -> NSURL? {
		let supportD = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
		let directoryPath = (supportD as NSString).stringByAppendingPathComponent(TEACHER_CHAT_PATH)
		if let sessionId = currentSessionId{
			let sessionFilePath = (directoryPath as NSString).stringByAppendingPathComponent("\(sessionId)")
			
			let fileManager = NSFileManager.defaultManager()
			do{
				if !fileManager.fileExistsAtPath(directoryPath) {
					try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
				}
				if !fileManager.fileExistsAtPath(sessionFilePath) {
					try fileManager.createDirectoryAtPath(sessionFilePath, withIntermediateDirectories: true, attributes: nil)
				}
			}catch{
				printDebug("error in creating directory for audio file")
			}
			
			let url = NSURL(fileURLWithPath: sessionFilePath)
			return url
			
		}
	 return nil
	}
	
	class func localFilePathForUrl(previewUrl: String,currentSessionId:String?) -> NSURL? {
		let supportD = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
		printDebug("previewUrl \(previewUrl) url \(NSURL(string: previewUrl)) ****")
		let path = previewUrl.stringByReplacingOccurrencesOfString(" ", withString: "%20")
		if let url = NSURL(string: path),let lastPathComponent = url.lastPathComponent {
			let fileManager = NSFileManager.defaultManager()
			
			let directoryPath = (supportD as NSString).stringByAppendingPathComponent(TEACHER_CHAT_PATH)
			var filePath = (directoryPath as NSString).stringByAppendingPathComponent(lastPathComponent)
			
			
			do{
				if !fileManager.fileExistsAtPath(directoryPath) {
					try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
				}
				if let id = currentSessionId{
					let sessionFilePath = (directoryPath as NSString).stringByAppendingPathComponent(id)
					filePath = (sessionFilePath as NSString).stringByAppendingPathComponent(lastPathComponent)
					
					if !fileManager.fileExistsAtPath(sessionFilePath) {
						try fileManager.createDirectoryAtPath(sessionFilePath, withIntermediateDirectories: true, attributes: nil)
					}
				}
			}catch{
				printDebug("error in creating directory for audio file")
			}
			return NSURL(fileURLWithPath:filePath)
		}
		return nil
	}



}
