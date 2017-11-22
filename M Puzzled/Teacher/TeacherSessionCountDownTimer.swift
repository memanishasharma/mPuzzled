//
//  TeacherSessionCountDownTimer.swift
//  Hello English
//
//  Created by Manisha on 22/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

protocol TeacherTimerDidFinish {
	func sessionFinish()
}
class TeacherSessionCountDownTimer:NSObject{
	var view : UIView?
	var label:UILabel?
	var seconds = 1200
	var timer = NSTimer()
	var isTimerRunning = false
	var delegate:TeacherTimerDidFinish!
	
	
	init(view:UIView,label:UILabel,seconds:Int,delegate:TeacherTimerDidFinish){
		self.view = view
		self.label = label
		self.seconds = seconds
		self.delegate = delegate
		super.init()
		self.runTimer()
	}
	deinit {
		self.timer.invalidate()
	}
	
	
	func runTimer() {
		
		timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
	}
	
	func updateTimer() {
		if seconds < 61{
			self.view?.backgroundColor = UIColor.redColorCA()
		}
		if seconds < 1 {
			timer.invalidate()
			self.label?.text = "Time over"
			delegate.sessionFinish()
		} else {
			seconds -= 1
			self.label?.text = timeString(NSTimeInterval(seconds))
			
			if Prefs.stringForKey(Prefs.KEY_TEACHER_CHAT_TIME) != nil{
			   Prefs.removeObjectForKey(Prefs.KEY_TEACHER_CHAT_TIME)
			   Prefs.setObject(timeString(NSTimeInterval(seconds)), forKey: Prefs.KEY_TEACHER_CHAT_TIME)
			}else{
				Prefs.setObject(timeString(NSTimeInterval(seconds)), forKey: Prefs.KEY_TEACHER_CHAT_TIME)
			}
			
		}
		
	}
	
	func timeString(time:NSTimeInterval) -> String {
		let minutes = Int(time) / 60 % 60
		let seconds = Int(time) % 60
		return String(format:"%02d : %02d", minutes, seconds)
	}
}
