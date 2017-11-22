//
//  PaymentServerMethodCall.swift
//  Hello English
//
//  Created by Manisha on 20/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

var PAYTM_TEST_PAYMENT = 0

class PaymentServerMethodCall:NSObject{
	
	class func getPublicKey()->String{
	   let RAZORPAY_PUBLIC_KEY = "rzp_test_8iZSqzNXEAwNyF"
       var keyToBeReturned =  RAZORPAY_PUBLIC_KEY
	
		if let key = Prefs.stringForKey(Prefs.KEY_PAYMENT_PUBLIC_KEY){
		    if key != ""{
				keyToBeReturned =  key
			}
		}
		return keyToBeReturned
	
	}
	

	class func InitiateTransactionWithRazorPayTask(optionJson:[String:NSObject])->Int?{
		
		var isTestPayment = 0
		let purchaseKey = getPublicKey()
		
		if purchaseKey.containsString("test"){
			isTestPayment = 1
		}
		
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL),let product = optionJson["product"] as? String,let price = optionJson["india_price"] as? Float{
		var params = [RequestParam(key: "payments", value: "true")]
		params.append(RequestParam(key: "email", value: email))
		params.append(RequestParam(key: "amount", value:"\(price)"))
		params.append(RequestParam(key: "product", value: product))
		params.append(RequestParam(key: "currency", value: "Rs"))
		params.append(RequestParam(key: "paymentChannel", value: "RazorPay"))
		params.append(RequestParam(key: "isTestPayment", value: "\(isTestPayment)"))
			do{
				let response = try ServerInterface.callSync(PHPAction.INITIATE_TRANSACTION, params: params, jsonType: .JSONObject)
				
				if let success = response.jsonObject?["success"] as? Int{
				 printDebug("success ")
					return success
				}
			}catch{
				printDebug("error in initiate transaction \(error)")
			}
		}else{
			printDebug("action calling failed")
		}
		
		return nil
	}
	
	class func ResponseToServerTaskForRazorPayTask(optionJson:[String:String])->Bool{
		
		if let email = optionJson["email"],let status = optionJson["status"],let id = Prefs.stringForKey(Prefs.KEY_PAYMENT_UNIQUE_ID),let transcId = optionJson["razorpay_payment_id"]{
			var params = [RequestParam(key: "email", value: email)]
			params.append(RequestParam(key: "uniqueID_CA", value:id))
			params.append(RequestParam(key: "transactionId", value: transcId))
			params.append(RequestParam(key: "payments", value: "true"))
			params.append(RequestParam(key: "status", value: status))
			do{
				let response = try ServerInterface.callSync(PHPAction.FINISH_TRANSACATION, params: params, jsonType: .JSONObject)
				
				if let success = response.jsonObject?["success"] as? String{
				 printDebug("success ")
					runOnUIThread({
					  Toast.makeToastWithText(success, duration: .Small)
					})
					return true
				}else if let error = response.jsonObject?["error"] as? String{
					runOnUIThread({
					  Toast.makeToastWithText(error, duration: .Small)
						})
				}else{
					runOnUIThread({
						Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
					})
				}
			}catch{
				runOnUIThread({
					Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
				})
				printDebug("error in initiate transaction \(error)")
			}
		
		}else{
			runOnUIThread({
				Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
			})
			printDebug("action calling failed")
		}
		return false
	}

	class func InitiateTransactionWithPayTmTask(optionJson:[String:NSObject])->[String:NSObject]?{
		
		let isTestPayment = "\(PAYTM_TEST_PAYMENT)"
		
		var currency:String?
		var price:String?
		
		if let locationCountry = Prefs.stringForKey(Prefs.KEY_LOCATION_COUNTRY),let indPrice = optionJson["india_price"] as? Float, let otherPrice = optionJson["other_price"] as? Float{
			printDebug("locationCountry \(locationCountry)")
			if locationCountry == "India" || locationCountry == "INDIA" || locationCountry == "india" {
				currency = "india_currency"
				price = "\(indPrice)"
			}else{
				currency = "other_currency"
				price = "\(otherPrice)"
			}
		}
		
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL),let product = optionJson["product"] as? String,let _currency = currency,let _price = price{
			var params = [RequestParam(key: "payments", value: "true")]
			params.append(RequestParam(key: "email", value: email))
			params.append(RequestParam(key: "amount", value: _price))
			params.append(RequestParam(key: "product", value: product))
			params.append(RequestParam(key: "currency", value: _currency))
			params.append(RequestParam(key: "isTestPayment", value: isTestPayment))
			
			do{
				let response = try ServerInterface.callSync(PHPAction.INITIATE_PAYTM_TRANSACTION, params: params, jsonType: .JSONObject)
				
				if let success = response.jsonObject?["success"] as? [String:NSObject]{
				 printDebug("success ")
					return success
				}
			}catch{
				printDebug("error in initiate transaction \(error)")
			}
		}else{
			printDebug("action calling failed")
		}
		
		return nil
	}

	
}

