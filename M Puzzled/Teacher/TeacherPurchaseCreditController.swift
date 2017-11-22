//
//  TeacherPurchaseCreditController.swift
//  Hello English
//
//  Created by Manisha on 20/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

protocol PaymentProtocol{
	func onSuccessPopToRootView(status:Bool)
}
class TeacherPurchaseCreditController:UIViewController,PaymentProtocol{
	
	@IBOutlet var backButton: UIButton!
	
	@IBOutlet var navBarHeadingLabel: UILabel!
	
	@IBOutlet var headingLabel: UILabel!
	
	@IBOutlet var couponCodetextField: UITextField!
	
	@IBOutlet var paymentOptionContainerView: UIView!
	
	@IBOutlet var scrollView: UIScrollView!
	
	@IBOutlet var downloadIndicator: UIActivityIndicatorView!
	
	var type :String = ""
	var popToViewController: UIViewController!
	var rootViewController: UIViewController!
	var object: PaymentUsingRazorPay!
	//var paytmObject: PaymentUsingPayTm!
	var content = [[String:NSObject]]()
	var bottomConstraint: NSLayoutConstraint!
	var data: [String:NSObject]!
	
	override func viewDidLoad(){
		super.viewDidLoad()
		backButton.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
		headingLabel.text = "\(LocalizedString("paymentMethod", comment: ""))"
		content = [
			["heading": "\(LocalizedString("razorpay_payment", comment: ""))",
				"type": "netBanking",
				"image":"banking"
			],
			["heading": "\(LocalizedString("debit_credit_payment", comment: ""))",
				"type": "debitCreditCard",
				"image": "card"
			],
			["heading": "\(LocalizedString("paytm_wallet", comment: ""))",
				"type": "paytm",
				"image": "wallet"
			],
			["heading": "\(LocalizedString("google_payment", comment: ""))",
				"type": "google",
				"image": "wallet"
			],
			["heading": "\(LocalizedString("paytm_payment", comment: ""))",
				"type": "other",
				"image": "wallet"
			]
		]
		
		for i in 0..<content.count{
			addView(i)
		}
		
		if let locationCountry = Prefs.stringForKey(Prefs.KEY_LOCATION_COUNTRY),let item = self.data{
			printDebug("locationCountry \(locationCountry)")
			if locationCountry == "India"{
				let credit = item["credit"] as? Int
				let price = item["india_price"] as? Float
				if let _price = price ,let _credit = credit{
					navBarHeadingLabel.text = "Buy"+" "+"\(_credit)"+" "+"Credits for "+"Rs"+" "+"\(_price)"
					
				}
			}else{
				let credit = item["credit"] as? Int
				let price = item["other_price"] as? Float
				if let _price = price ,let _credit = credit{
					let dolar: String = "\u{0024}"
					navBarHeadingLabel.text = "Buy"+" "+"\(_credit)"+" "+"Credits for "+" "+"\(_price)"+" "+"\(dolar)"
				}
			}
			
		}
		
		//		netBankingLabel.text = "\(LocalizedString("razorpay_payment", comment: ""))"
		//		debitCreditLabel.text = "\(LocalizedString("debit_credit_payment", comment: ""))"
		//		paytmLabel.text = "\(LocalizedString("paytm_wallet", comment: ""))"
		//		googleWalletLabel.text = "\(LocalizedString("google_payment", comment: ""))"
		//		otherWalletLabel.text = "\(LocalizedString("paytm_payment", comment: ""))"
		//
		if downloadIndicator.isAnimating(){
		downloadIndicator.stopAnimating()
		}
	}
	override func viewWillAppear(animated:Bool){
		super.viewWillAppear(animated)
		
		//		self.netBankingView.gestureRecognizers = [UITapGestureRecognizer(target:self,action:#selector(paymentOptionSelector(_:)))]
		//		self.debitCreditCardView.gestureRecognizers = [UITapGestureRecognizer(target:self,action:#selector(paymentOptionSelector(_:)))]
		//		self.paytmView.gestureRecognizers = [UITapGestureRecognizer(target:self,action:#selector(paymentOptionSelector(_:)))]
		//		self.googleWalletView.gestureRecognizers = [UITapGestureRecognizer(target:self,action:#selector(paymentOptionSelector(_:)))]
		//		self.otherWalletView.gestureRecognizers = [UITapGestureRecognizer(target:self,action:#selector(paymentOptionSelector(_:)))]
		//		netBankingView.userInteractionEnabled = true
		//		debitCreditCardView.userInteractionEnabled = true
		//		netBankingView.userInteractionEnabled = true
		//		googleWalletView.userInteractionEnabled = true
		//		otherWalletView.userInteractionEnabled = true
		
	}
	
	
	func makeViewWithLabel(index:Int)->(customView: UIView, constraints: [NSLayoutConstraint]){
		
		let customView = UIView()
		customView.translatesAutoresizingMaskIntoConstraints = false
		
		let label: UILabel = UILabel()
		label.textAlignment = NSTextAlignment.Left
		label.text = "test label"
		
		let imageView:UIImageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		if let title = content[index]["heading"] as? String,let image = content[index]["image"]{
			label.text = title
			imageView.image = UIImage(named: "\(image)")
		}else{
			printDebug("no label found")
		}
		
		label.textColor = UIColor.blueColorCA()
		if UI_USER_INTERFACE_IDIOM() == .Pad {
			label.font = UIFont.systemFontOfSize(25)
			
		} else {
			label.font = UIFont.systemFontOfSize(15)
		}
		label.translatesAutoresizingMaskIntoConstraints = false
		
		customView.addSubview(label)
		customView.addSubview(imageView)
		
		let ld = NSLayoutConstraint(item:imageView,
		                            attribute: NSLayoutAttribute.Leading,
		                            relatedBy: NSLayoutRelation.Equal ,
		                            toItem:imageView.superview!,
		                            attribute: NSLayoutAttribute.Leading,
		                            multiplier: 1.0,
		                            constant: 20.0)
		let ldLabel = NSLayoutConstraint(item:imageView,
		                                 attribute: NSLayoutAttribute.Trailing,
		                                 relatedBy: NSLayoutRelation.Equal ,
		                                 toItem:label,
		                                 attribute: NSLayoutAttribute.Leading,
		                                 multiplier: 1.0,
		                                 constant: -10.0)
		
		
		let w = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal,
		                           toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 24)
		
		let h = NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal,
		                           toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 24)
		
		
		let c = NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: imageView.superview!, attribute: .CenterY, multiplier: 1, constant: 0)
		
		
		let tr = NSLayoutConstraint(item:label,
		                            attribute: NSLayoutAttribute.Trailing,
		                            relatedBy: NSLayoutRelation.Equal ,
		                            toItem: label.superview,
		                            attribute: NSLayoutAttribute.Trailing,
		                            multiplier: 1.0,
		                            constant: 0.0)
		
		let t = NSLayoutConstraint(item:label,
		                           attribute: NSLayoutAttribute.Top,
		                           relatedBy: NSLayoutRelation.Equal ,
		                           toItem:label.superview!,
		                           attribute: NSLayoutAttribute.Top,
		                           multiplier: 1.0,
		                           constant: 20.0)
		
		let b = NSLayoutConstraint(item: label.superview!,
		                           attribute: NSLayoutAttribute.Bottom,
		                           relatedBy: NSLayoutRelation.Equal ,
		                           toItem: label,
		                           attribute: NSLayoutAttribute.Bottom,
		                           multiplier: 1.0,
		                           constant: 20.0)
		
		return (customView, [b, tr, t,ld,ldLabel,h,w,c])
	}
	
	func addView(index :Int){
		
		var lastSubview = UIView()
		if !self.paymentOptionContainerView.subviews.isEmpty{
			lastSubview = self.paymentOptionContainerView.subviews.last!
		}
		let data = makeViewWithLabel(index)
		let customView = data.customView
		var constraints = [NSLayoutConstraint]()
		customView.translatesAutoresizingMaskIntoConstraints = false
		customView.tag = index
		self.paymentOptionContainerView.addSubview(customView)
		constraints.appendContentsOf(data.constraints)
		customView.backgroundColor = UIColor.whiteColor()
		let leadingConstraint = NSLayoutConstraint(item: self.paymentOptionContainerView.subviews.last!,
		                                           attribute: NSLayoutAttribute.Leading,
		                                           relatedBy: NSLayoutRelation.Equal ,
		                                           toItem: self.paymentOptionContainerView ,
		                                           attribute: NSLayoutAttribute.Leading,
		                                           multiplier: 1.0,
		                                           constant: 20)
		constraints.append(leadingConstraint)
		let trailingConstraint = NSLayoutConstraint(item:self.paymentOptionContainerView.subviews.last!,
		                                            attribute: NSLayoutAttribute.Trailing,
		                                            relatedBy: NSLayoutRelation.Equal ,
		                                            toItem:  self.paymentOptionContainerView,
		                                            attribute: NSLayoutAttribute.Trailing,
		                                            multiplier: 1.0,
		                                            constant: 20.0)
		constraints.append(trailingConstraint)
		
		if self.paymentOptionContainerView.subviews.count == 1{
			let topConstraint = NSLayoutConstraint(item: self.paymentOptionContainerView.subviews.last!,
			                                       attribute: NSLayoutAttribute.Top,
			                                       relatedBy: NSLayoutRelation.Equal ,
			                                       toItem: self.paymentOptionContainerView,
			                                       attribute: NSLayoutAttribute.Top,
			                                       multiplier: 1.0,
			                                       constant: 10.0)
			constraints.append(topConstraint)
			
		}else{
			let topConstraint = NSLayoutConstraint(item:self.paymentOptionContainerView.subviews.last!,
			                                       attribute: NSLayoutAttribute.Top,
			                                       relatedBy: NSLayoutRelation.Equal ,
			                                       toItem: lastSubview,
			                                       attribute: NSLayoutAttribute.Bottom,
			                                       multiplier: 1.0,
			                                       constant: 10.0)
			constraints.append(topConstraint)
		}
		
		if content.count ==  paymentOptionContainerView.subviews.count{
			self.bottomConstraint = NSLayoutConstraint(item: self.paymentOptionContainerView,
			                                           attribute: NSLayoutAttribute.Bottom,
			                                           relatedBy: NSLayoutRelation.Equal ,
			                                           toItem: self.paymentOptionContainerView.subviews.last!,
			                                           attribute: NSLayoutAttribute.Bottom,
			                                           multiplier: 1.0,
			                                           constant: 10.0)
			constraints.append(bottomConstraint)
		}
		NSLayoutConstraint.activateConstraints(constraints)
		
		self.paymentOptionContainerView.layoutIfNeeded()
		self.view.layoutIfNeeded()
		
		let touch = UITapGestureRecognizer(target: self, action: #selector(paymentOptionSelector(_:)))
		self.paymentOptionContainerView.subviews[index].addGestureRecognizer(touch)
		//
		
		//		if let labelItem = self.paymentOptionContainerView.subviews[index].subviews[1] as? UILabel{
		//			labelItem.text = "headsing"
		//		}else{
		//			printDebug("no label found in view")
		//		}
		
		runOnUIThread({
			self.view.layoutIfNeeded()
			self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width, self.view.frame.height)
			printDebug("Before size \(self.scrollView.contentSize)*** \(self.view.frame)")
		})
		
	}
	
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		if UIDevice.currentDevice().orientation.isLandscape.boolValue {
			print("Landscape")
			runOnUIThread({
				self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width, self.view.frame.height)
				printDebug("size \(self.scrollView.contentSize)*** \(self.view.frame)")
			})
		}else {
			print("Portrait")
			runOnUIThread({
				self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width, self.view.frame.height)
				printDebug("Before size \(self.scrollView.contentSize)*** \(self.view.frame)")
			})
			
			//imageView.image = UIImage(named: const)
		}
		
	}
	
	
	
	func buttonClicked(sender:UIButton){
		
		if sender == backButton{
			if let popToViewController = self.popToViewController
				where self.navigationController?.viewControllers.contains(popToViewController) == true {
				self.navigationController?.popToViewController(popToViewController, animated: true)
			} else {
				self.navigationController?.popToRootViewControllerAnimated(true)
			}
		}
	}
	
	func paymentOptionSelector(sender: UITapGestureRecognizer){
		printDebug("touch payment option")
		runOnUIThread({
		self.downloadIndicator.startAnimating()
			})
		if let view = sender.view{
		let index = view.tag
		if let selectedView = self.content[index]["type"] as? String,let price = self.data["india_price"] as? Float,let credit = self.data["credit"] as? Int {
			
			if selectedView == "netBanking" || selectedView == "debitCreditCard" || selectedView == "googleWallet" || selectedView == "other"{
				
				if let key = PaymentServerMethodCall.InitiateTransactionWithRazorPayTask(self.data){
					
					let defaults = NSUserDefaults(suiteName: "HelloEnglish")
					defaults?.setObject("\(key)", forKey: Prefs.KEY_PAYMENT_UNIQUE_ID)
					
					let title = credit > 1 ?"\(credit) credits":  "\(credit) credit"
					self.object = PaymentUsingRazorPay(amount:"\(price*100)",courseTitle: title,delegate: self)
					self.object.initialiseKey()
				}
			}else if selectedView == "paytm"{
//				if let data = PaymentServerMethodCall.InitiateTransactionWithPayTmTask(self.data){
//				self.paytmObject = PaymentUsingPayTm(viewController: self,price: "\(price)",paymentDictionary: data)
//				self.paytmObject.initialise()
//				}
			}else{
				printDebug("no match found")
			}
			
		}else{
			printDebug("in else part \(self.content[index]["type"]) ** \(self.content[index]["india_price"])")
		}
		//		}else{
		//			printDebug("nil returned")
		//		}
		}
		
		
	}
	
	func onSuccessPopToRootView(status:Bool){
		if status{
		if let popToViewController = self.rootViewController
			where self.navigationController?.viewControllers.contains(popToViewController) == true {
			self.navigationController?.popToViewController(popToViewController, animated: true)
		} else {
			self.navigationController?.popToRootViewControllerAnimated(true)
		}
		}
		
		runOnUIThread({
			if self.downloadIndicator.isAnimating(){
				self.downloadIndicator.stopAnimating()
			}
		})
		
	}
	
}
