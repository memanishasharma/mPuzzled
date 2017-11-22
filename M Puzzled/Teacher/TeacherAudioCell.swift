//
//  TeacherAudioCell.swift
//  Hello English
//
//  Created by Manisha on 07/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

protocol TeacherAudioCellDelegate {
	func pauseTapped(cell: TeacherAudioCell)
	func resumeTapped(cell: TeacherAudioCell)
	func cancelTapped(cell: TeacherAudioCell)
	func downloadTapped(cell: TeacherAudioCell)
	func playButtonTapped(cell: TeacherAudioCell)
	func uploadButtonTapped(cell: TeacherAudioCell)
	//func sliderProgressTracker(cell: TeacherAudioCell)
}

class TeacherAudioCell:UITableViewCell{
	
	@IBOutlet var audioCircleTeacher: CircleView!
	
	@IBOutlet var audioCircleUser: CircleView!
	
	@IBOutlet var audioTimerlabel: UILabel!
	
	@IBOutlet var audioSliderView: UISlider!
	
	@IBOutlet var audioPostTimeLabel: UILabel!
	
	@IBOutlet var playerStateImageView: UIImageView!
	
	@IBOutlet var textAudioView: UIView!
	
	@IBOutlet var textAudioLabel: UILabel!
	
	@IBOutlet var textAudioHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var chatBubbleImageView: UIImageView!
	
	@IBOutlet var backGroundChatView: UIView!
	
	
	//MARK: Image Cell
	@IBOutlet var chatImageView: UIImageView!
	
	@IBOutlet var downloadOverlayView: UIView!
	
	@IBOutlet var downloadButton: UIView!
	
	@IBOutlet var downloadingView: UIView!
	
	@IBOutlet var chatTimerLabel: UILabel!
		
	var delegate: TeacherAudioCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		if let _playerStateImageView = playerStateImageView{
			_playerStateImageView.image = _playerStateImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			_playerStateImageView.tintColor = UIColor(hexString: "#7777777")
		}
	}
	
	func sliderProgressUpdater(value: Float){
		printDebug("slider value \(value)")
		self.audioSliderView.value = value
		
	}
	
	
	func pauseOrResumeTapped(sender: AnyObject) {

	}
	
	func playButtonTapped(sender: AnyObject){
		delegate?.playButtonTapped(self)
	}
	func cancelTapped(sender: AnyObject) {
		delegate?.cancelTapped(self)
	}
	
	func downloadTapped(sender: AnyObject) {
		delegate?.downloadTapped(self)
	}
	
	func uploadButtonTapped(sender: AnyObject) {
	   delegate?.uploadButtonTapped(self)
	}
	
	func removeAnimation(){
		if let view = audioCircleUser{
			view.animating = false
			view.tintColorChange()
		}
		
		if let view = audioCircleTeacher{
			view.animating = false
			view.tintColorChange()
		}
	}
	
	func animateCircle(){
		
		if let view = audioCircleUser{
			view.animating = true
			view.tintColorDidChange()
			view.updateAnimation()
		}
		if let view = audioCircleTeacher{
			view.animating = true
			view.tintColorDidChange()
			view.updateAnimation()
		}
	}
	
		
}
