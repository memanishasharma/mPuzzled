//
//  TeacherCell.swift
//  Hello English
//
//  Created by Manisha on 16/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

@objc
protocol PassDataFromTeacherTabelCell{
	optional func videoSetUpCompleteCall()
	
}



class TeacherCell: UITableViewCell,YTPlayerViewDelegate{
	
	//MARK:teacherVideoCell
	@IBOutlet var videoView: YTPlayerView!
	
	@IBOutlet var videoLoader: UIActivityIndicatorView!
	
	//Mark:teacherInfoCell
	@IBOutlet var infoHeading1Label: UILabel!
	
	
	@IBOutlet var howItWorkButton: UIButton!
	
	//Mark: teacherHeadingCell
	@IBOutlet var headingLabel: UILabel!
	
	//MARK: teacherMoreslot cell
	@IBOutlet var moreSlotButton: UIButton!
	
	//MARK: teacherSessionInfoCell
	@IBOutlet var slotTimerImageView: UIImageView!
	
	@IBOutlet var slotTimeLabel: UILabel!
	
	@IBOutlet var slotCreditLabel: UILabel!
	
	@IBOutlet var slotCreditImageView: UIImageView!
	
	//MARK: teacherOptionCell
	@IBOutlet var optionImageView: UIImageView!
	
	@IBOutlet var optionLabel: UILabel!
	
	
	//MARK: teacherCreditHistory
	@IBOutlet var thumbnailLabel: UILabel!
	
	@IBOutlet var thumbnailImageView: UIImageView!
	
	@IBOutlet var creditHeadingLabel: UILabel!
	
	@IBOutlet var creditTimeLabel: UILabel!
	
	@IBOutlet var creditLabel: UILabel!
	
	@IBOutlet var creditBalanceLabel: UILabel!
	
	
	//MARK:userBalanceCell
	@IBOutlet var showHistoryButton: UIButton!
	
	@IBOutlet var leftCreditLabel: UILabel!
	
	@IBOutlet var reviewSessionButton: UIButton!
	
	@IBOutlet var sessionTakenLabel: UILabel!
	
	//MARK:teacher booked session
	@IBOutlet var dateThumbnailView: UIImageView!
	
	@IBOutlet var dateHeadingLabel: UILabel!
	
	@IBOutlet var dateLabel: UILabel!
	
	@IBOutlet var timeThumbnailView: UIImageView!
	
	@IBOutlet var timeHeadingLabel: UILabel!
	
	@IBOutlet var timeLabel: UILabel!
	
	@IBOutlet var durationThumbnailView: UIImageView!
	
	@IBOutlet var durationHeadingLabel: UILabel!
	
	@IBOutlet var durationLabel: UILabel!
	
	@IBOutlet var topichumbnailView: UIImageView!
	
	@IBOutlet var topicHeadingLabel: UILabel!
	
	@IBOutlet var topicLabel: UILabel!
	
	@IBOutlet var pricehumbnailView: UIImageView!
	
	@IBOutlet var priceHeadingLabel: UILabel!
	
	@IBOutlet var priceLabel: UILabel!
	
	//MARK: UserTextMessageCell
	@IBOutlet var userTextMessageLabel: UILabel!
	
	//MARK: TeacherTextMessageCell
	@IBOutlet var teacherTextMessageLabel: UILabel!
	
	//MARK: SessionCell
	@IBOutlet var sessionHeadingLabel: UILabel!
	
	@IBOutlet var sessionTimeLabel: UILabel!
	
	@IBOutlet var chatBubbleImageView: UIImageView!
	
	@IBOutlet var backGroundChatView: UIView!
	
	@IBOutlet var chatTimerLabel: UILabel!
	
	//MARK: teacherNoInternet alert
	@IBOutlet var teacherNoInternetLabel: UILabel!
	
	@IBOutlet var teacherTryAgainButton: UIButton!
	
	var indexPath: NSIndexPath!
	var delegate: PassDataFromTeacherTabelCell?
	
	
	var isloaded:Bool = true
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if let button = howItWorkButton{
			button.setTitle("HOW IT WORKS?", forState: .Normal)
		}
		
		if let imageView = slotCreditImageView{
			imageView.image = UIImage(named: "ic_credit_card_black_24dp")
			imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIColor.blueColorCA().colorWithAlphaComponent(0.54)
			
		}
		if let _videoLoader = videoLoader{
			if _videoLoader.isAnimating(){
				_videoLoader.stopAnimating()
				_videoLoader.hidden = true
			}
		}
		
		if let imageView = slotTimerImageView{
			imageView.image = UIImage(named: "ic_access_time_48pt")
			imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			imageView.tintColor = UIColor.blueColorCA().colorWithAlphaComponent(0.54)
			
		}
		
		if let youTubePlayer = videoView{
			if isloaded == true{
				isloaded = false
				let playerVars = ["modestbranding": 0,"rel":0,"playsinline": 1,"fs":0 ,"autohide": 1]
				youTubePlayer.delegate = self
				youTubePlayer.loadWithVideoId("JxnyYsw9hpI", playerVars: playerVars)
			}
		}
		
		if let view = thumbnailImageView{
			if isPad(){
				view.layer.cornerRadius = 80/2
			}else{
				view.layer.cornerRadius = 50/2
			}
		}
		
		if let view = thumbnailLabel{
			if isPad(){
				view.layer.cornerRadius = 80/2
			}else{
				view.layer.cornerRadius = 50/2
			}
		}
	}
	
	//MARK: youtube delegate method
	func playerViewDidBecomeReady(playerView: YTPlayerView) {
		self.delegate?.videoSetUpCompleteCall!()
		
	}
	
	func playerView(playerView: YTPlayerView, didPlayTime playTime: Float) {
	}
	
	func playerView(playerView: YTPlayerView, didChangeToState state: YTPlayerState) {
	}
	
	func playerViewPreferredWebViewBackgroundColor(playerView: YTPlayerView) -> UIColor {
		return UIColor.clearColor()
	}
	
	func clearVideoResource(){
		if let player = self.videoView{
			if player.playerState().rawValue == 1{
				player.stopVideo()
			}
			let state = player.playerState().rawValue
			switch state {
			case (-1 ... 2) : player.removeWebView()
			default: printDebug("Nothing to do")
			}
		}
		self.videoView = nil
	}
}
