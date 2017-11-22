//
//  TeacherAudioRecordTimer.swift
//  Hello English
//
//  Created by Manisha on 02/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
class TeacherAudioRecordTimer:NSObject{
	var label:UILabel?
	
	init(label:UILabel){
		self.label = label
		super.init()
		self.runTimer()
	}
	
	deinit {
		self.timer.invalidate()
		self.timer = NSTimer()
	}
	
	static var instancesOfSelf = [TeacherAudioRecordTimer]()
	var seconds = 0
	var timer = NSTimer()
	//var isTimerRunning = false
	
	func runTimer() {
		self.label?.text = String(format:"%02d sec / 30 sec", 0)
		timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
	}
	
	func updateTimer() {
			seconds += 1
		    printDebug("seconds \(seconds)")
			self.label?.text = timeString(NSTimeInterval(seconds))
	}
	
	func timeString(time:NSTimeInterval) -> String {
		let seconds = Int(time) % 60
		return String(format:"%02d sec / 30 sec", seconds)
	}
	
	
	
}
