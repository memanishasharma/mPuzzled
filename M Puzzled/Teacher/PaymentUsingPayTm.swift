////
////  PaymentUsingPayTm.swift
////  Hello English
////
////  Created by Manisha on 21/06/17.
////  Copyright © 2017 CultureAlley. All rights reserved.
////
//
//import Foundation
//
//class PaymentUsingPayTm: NSObject,PGTransactionDelegate{
//	
//	
//	var txnID: String!
//	var order_id: String!
//	var Refund: String!
//	var viewController:UIViewController?
//	var addedController:PGTransactionViewController?
//	private var paymentDictionary:[String:NSObject]?
//	private var price:String?
//	
//	init(viewController:UIViewController,price:String,paymentDictionary:[String:NSObject]){
//		self.viewController = viewController
//		self.price = price
//		self.paymentDictionary = paymentDictionary
//	}
//	
//	class func generateOrderIDWithPrefix(prefix: String) -> String {
//		
//		srandom(UInt32(time(nil)))
//		
//		let randomNo = arc4random();        //just randomizing the number
//		let orderID: String = "\(prefix)\(randomNo)"
//		return orderID
//		
//	}
//	
//	func showController(controller: PGTransactionViewController) {
//		addedController = controller
//		if self.viewController?.navigationController != nil {
//			self.viewController?.navigationController!.pushViewController(controller, animated: true)
//		}
//		else {
//			self.viewController?.presentViewController(controller, animated: true, completion: {() -> Void in
//			})
//		}
//	}
//	
//	func removeController(controller: PGTransactionViewController) {
//		if self.viewController?.navigationController != nil {
//			self.viewController?.navigationController!.popViewControllerAnimated(true)
//		}
//		else {
//			self.viewController?.dismissViewControllerAnimated(true, completion: {() -> Void in
//			})
//		}
//	}
//	
//	
//	func initialise(){
//		
//		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL),let price = price,let _paymentDictionary = paymentDictionary{
//			//Step 1: Create a default merchant config object
//			let mc: PGMerchantConfiguration = PGMerchantConfiguration.defaultConfiguration()
//			
//			//Step 2: If you have your own checksum generation and validation url set this here. Otherwise use the default Paytm urls
//			
//			mc.checksumGenerationURL = "https://helloenglish.com/paytmCSumGen_1469620177690.jsp"
//			mc.checksumValidationURL = "https://helloenglish.com/paytmCSumVerify_1469620197982.jsp"
//			
//			//Step 3: Create the order with whatever params you want to add. But make sure that you include the merchant mandatory params
//			var orderDict: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
//			
//			
////			orderDict["MID"] = "WorldP64425807474247"
////			//Merchant configuration in the order object
////			orderDict["CHANNEL_ID"] = "WAP"
////			orderDict["INDUSTRY_TYPE_ID"] = "Retail"
////			orderDict["WEBSITE"] = "worldpressplg"
////			//Order configuration in the order object
////			orderDict["TXN_AMOUNT"] = "5"
////			orderDict["ORDER_ID"] = ViewController.generateOrderIDWithPrefix("")
////			orderDict["REQUEST_TYPE"] = "DEFAULT"
////			orderDict["CUST_ID"] = "1234567890"
////			
//			
//			orderDict["ORDER_ID"] = _paymentDictionary["ORDER_ID"]
//			orderDict["MID"] = _paymentDictionary["MID"]
//			orderDict["CUST_ID"] = _paymentDictionary["CUST_ID"]
//			orderDict["CHANNEL_ID"] = _paymentDictionary["CHANNEL_ID"]
//			orderDict["INDUSTRY_TYPE_ID"] = _paymentDictionary["INDUSTRY_TYPE_ID"]
//			orderDict["WEBSITE"] = _paymentDictionary["WEBSITE"]
//			orderDict["TXN_AMOUNT"] = price
//			orderDict["THEME"] = _paymentDictionary["THEME"]
//			orderDict["EMAIL"] = email
//			orderDict["MOBILE_NO"] = "9958479074"
//			orderDict["REQUEST_TYPE"] = _paymentDictionary["REQUEST_TYPE"]
//			
//			let order: PGOrder = PGOrder(params: orderDict)
//			
//			
//			//Step 4: Choose the PG server. In your production build dont call selectServerDialog. Just create a instance of the
//			//PGTransactionViewController and set the serverType to eServerTypeProduction
//			PGServerEnvironment.selectServerDialog(self.viewController!.view, completionHandler: {(type: ServerType) -> Void in
//				
//				let txnController = PGTransactionViewController.init(transactionForOrder: order)
//				
//				
//				if type != eServerTypeNone {
//					txnController.serverType = type
//					txnController.merchant = mc
//					txnController.delegate = self
//					self.showController(txnController)
//				}
//			})
//		}
//		
//	}
//	//MARk:Delegate method
//	
//	func didFinishedResponse(controller: PGTransactionViewController!, response responseString: String!) {
//		printDebug("response \(responseString)")
//		//printDebug("ViewController::didSucceedTransactionresponse= %@", response)
//		//let msg: String = "Your order was completed successfully.\n Rs. \(response["TXNAMOUNT"]!)"
//		
//		
//		//self.function.alert_for("Thank You for Payment", message: msg)
//		self.removeController(controller)
//		
//		//		print("ViewController::didFailTransaction error = %@ response= %@", error, response)
//		//
//		//		if response.count == 0 {
//		//
//		//			self.function.alert_for(error.localizedDescription, message: response.description)
//		//
//		//		}
//		//		else if error != 0 {
//		//
//		//			self.function.alert_for("Error", message: error.localizedDescription)
//		//
//		//
//		//		}
//		//
//		//		self.removeController(controller)
//	}
//	
//	func didCancelTrasaction(controller: PGTransactionViewController!) {
//		
//		printDebug("going to remove this controller")
//		//		var msg: String? = nil
//		//
//		//		if error != 0 {
//		//
//		//			msg = String(format: "Successful")
//		//		}
//		//		else {
//		//			msg = String(format: "UnSuccessful")
//		//		}
//		//
//		//
//		//		self.function.alert_for("Transaction Cancel", message: msg!)
//		
//		self.removeController(controller)
//	}
//	
//	func errorMisssingParameter(controller: PGTransactionViewController!, error: NSError!) {
//		printDebug("error message error \(error)")
//		didCancelTrasaction(addedController)
//	}
//	
//	
//}
