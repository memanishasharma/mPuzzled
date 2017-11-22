//
//  Track.swift
//  Hello English
//
//  Created by Manisha on 07/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
class Track {
	var previewUrl: String?
	var id: String?
	var type: String?
	var time:String?
	
	init( previewUrl: String?,id: String?,type: String?,time: String?) {
		self.previewUrl = previewUrl
		self.id = id
		self.type = type
		self.time = time
		printDebug("self.id \(self.id) type \(self.type) time \(self.time) self.previewUrl \(self.previewUrl)")
	}
	
}
