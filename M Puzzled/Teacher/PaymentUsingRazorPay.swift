//
//  PaymentUsingRazorPay.swift
//  Hello English
//
//  Created by Manisha on 20/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation


class PaymentUsingRazorPay:NSObject,RazorpayPaymentCompletionProtocol{
	private var razorpay : Razorpay!
	private var razorPayPublicKey = "rzp_test_8iZSqzNXEAwNyF"
	private var amount:String?
	private var courseTitle:String = ""
	private var delegate:PaymentProtocol!

	init(amount: String?,courseTitle:String,delegate:PaymentProtocol){
		self.amount = amount
		self.courseTitle = courseTitle
		self.delegate = delegate
	}
	
	func initialiseKey(){
		self.razorPayPublicKey = PaymentServerMethodCall.getPublicKey()
		razorpay = Razorpay.initWithKey(razorPayPublicKey, andDelegate: self)
		showPaymentForm()
	}
	func showPaymentForm() {
	
		var email = ""
		if let _email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			email = _email
		}
		printDebug("amount in razorPay \(amount)")
		if let price = self.amount{
			let options = [
				"amount" : "\(price)", // and all other options,
				"name":"Hello English",
				"description":"\(courseTitle)",
				"image": "https://s3.amazonaws.com/language-practice/English-App/H_logo_square_300.png",
				"prefill": [
					"email":"\(email)",
					"name":"",
					"contact":""
				],
				"currency": "INR"
			]
			razorpay.open(options as [NSObject : AnyObject])
		}else{
			Toast.makeToastWithText("Payment Error", duration: .Small)
		}
		
	}
	
	
	func onPaymentSuccess(payment_id: String) {
		//UIAlertView.init(title: "Payment Successful", message: payment_id, delegate: self, cancelButtonTitle: "OK").show()
		Toast.makeToastWithText("Payment Successfull", duration: .Small)
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
		    var paramsJson = [String:String]()
			paramsJson["razorpay_payment_id"] = payment_id
			paramsJson["email"] = email
			paramsJson["status"] = "success"
			let status = PaymentServerMethodCall.ResponseToServerTaskForRazorPayTask(paramsJson)
			if status{
				self.delegate.onSuccessPopToRootView(true)
			}
		}
		
	}
	
	func onPaymentError(code: Int32, description str: String) {
		Toast.makeToastWithText("Payment Error", duration: .Small)
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			var paramsJson = [String:String]()
			paramsJson["razorpay_payment_id"] = ""
			paramsJson["email"] = email
			paramsJson["status"] = "failed"
			let status = PaymentServerMethodCall.ResponseToServerTaskForRazorPayTask(paramsJson)
			if status{
				self.delegate.onSuccessPopToRootView(false)
			}
		}
	}
	
}
