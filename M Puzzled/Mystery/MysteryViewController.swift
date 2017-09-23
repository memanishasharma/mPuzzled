//
//  MysteryViewController.swift
//  M Puzzled
//
//  Created by Manisha on 04/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import UIKit

class MysteryViewController: UIViewController{
	
	@IBOutlet var bgView: UIView!
	@IBOutlet var mainContainerView: UIView!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var questionHeadingLabel: UILabel!
	@IBOutlet var questionLabel: UILabel!
	@IBOutlet var closeView: UIView!
	@IBOutlet var infoImageView: UIImageView!
	@IBOutlet var customNavBarView: UIView!
	@IBOutlet var infoLeftImageView: UIImageView!
	
	var backgroundColor:UIColor?
	var questionHeading = ""
	var questionData = ""
	var delegate: CenterViewControllerDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mainContainerView.backgroundColor = UIColor.FlatColor.materialColor.Alizarin
		bgView.backgroundColor = UIColor.FlatColor.materialColor.Alizarin.withAlphaComponent(0.6)
		mainContainerView.drawBorder()
		customNavBarView.drawBorder()
		customNavBarView.backgroundColor = UIColor.FlatColor.materialColor.Alizarin.withAlphaComponent(0.6)
		bgView.drawBorder()
		
		questionLabel.font = UIFont(name: "Roboto-Light", size: 20)
		questionHeadingLabel.font = UIFont(name: "Roboto-Light", size: 24)
		
		closeView.dropShadow()
		customNavBarView.dropShadow()
		bgView.dropShadow()
		
		closeView.backgroundColor = UIColor.FlatColor.materialColor.Alizarin.withAlphaComponent(0.6)
		infoImageView.drawTint(color: UIColor.white)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didClickImageView(_:)))
		infoImageView?.gestureRecognizers = [tapGesture]
		infoImageView?.isUserInteractionEnabled = true
		
		infoLeftImageView.drawTint(color: UIColor.white)
		let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.didClickImageView(_:)))
		infoLeftImageView?.gestureRecognizers = [tapGesture2]
		infoLeftImageView?.isUserInteractionEnabled = true
		
		
		questionLabel.text = questionData
		questionHeadingLabel.text = questionHeading
	}
	
	@objc func didClickImageView( _ sender : UITapGestureRecognizer){
	
		if sender.view == infoImageView{
		delegate?.toggleRightPanel?()
		}else if sender.view == infoLeftImageView{
			delegate?.toggleLeftPanel?()
		}
	}
	@IBAction func closeDidClick(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
}
