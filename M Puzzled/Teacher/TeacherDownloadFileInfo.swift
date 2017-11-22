//
//  TeacherDownloadFileInfo.swift
//  Hello English
//
//  Created by Manisha on 13/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

class TeacherDownloadFileInfo: NSObject {
	var url: String
	var isDownloading = false
	var progress: Float = 0.0
	var id:String
	var downloadTask: NSURLSessionDownloadTask?
	var resumeData: NSData?
	
	init(url: String,id: String) {
		self.url = url
		self.id = id
	
	}
	
}
