//
//  TeacherCreditHistoryViewController.swift
//  Hello English
//
//  Created by Manisha on 17/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

class TeacherCreditHistoryViewController:CAViewController,UITableViewDelegate,UITableViewDataSource{
	
	@IBOutlet var backButton: UIButton!
	
	@IBOutlet var navBarHeadingLabel: UILabel!
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var downloadIndicator: UIActivityIndicatorView!
	var type :String = ""
	var popToViewController: UIViewController!
	var data:[[String:NSObject]]?
	var userBalance:[String:NSObject]?
	
	override func viewDidLoad(){
		super.viewDidLoad()
		backButton.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		
		dispatch_async(queue) { () -> Void in
			
			self.fetchUserCreditBalance()
			self.fetchCreditPriceListFromServer()
		}
     }
	
	override func viewWillAppear(animated:Bool){
		super.viewWillAppear(animated)
		runOnUIThread({
			self.downloadIndicator.startAnimating()
		})
	}
	
	func loadTableView(){
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.estimatedRowHeight = 150
		self.tableView.reloadData()
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//		var count = 3
		//		if let data = sessionData{
		//			let dataCount = data.count
		//			if dataCount >= 3{
		//				count += 4
		//			}
		//		}
		
		var noOfRows = 1
		if let data = self.data{
			noOfRows += data.count
		}
		printDebug("noOfRows \(noOfRows)")
		return noOfRows
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if indexPath.row == 0{
			if let cell = self.tableView.dequeueReusableCellWithIdentifier("headerCell") as? TeacherCell{
				cell.headingLabel.text = "Available Balance : "
				//totalCredits+(totalCredits > 1 ? " Credits" : "Credit"
				if let data = userBalance{
					printDebug("userBalance \(userBalance)")
					if let balance = integerValueFromJSON(data, forKey: "balance"){
						cell.headingLabel.text = "Available Balance: " + " \(balance)" + "\((balance > 1 ? " Credits" : " Credit"))"
					}
					cell.selectionStyle = .None
					return cell
				}
			}
		}else{
			if let data = self.data{
				if let cell = self.tableView.dequeueReusableCellWithIdentifier("creditHistoryCell") as? TeacherCell{
					cell.thumbnailLabel.text = "A"
					
					if let type = data[indexPath.row-1]["TRANSACTION_TYPE"] as? String{
						if type == "DEBIT"{
							cell.creditHeadingLabel.text = "Paid for session"
							cell.thumbnailImageView.backgroundColor = UIColor.redColorCA().colorWithAlphaComponent(0.8)
							//cell.thumbnailLabel.backgroundColor = UIColor.redColorCA().colorWithAlphaComponent(0.8)
							cell.thumbnailLabel.text = "D"
							if let amount = data[indexPath.row-1]["AMOUNT"] as? String{
								cell.creditLabel.text = "-"+"\(amount)"+" credit"
							}
							
						}else if type == "CREDIT"{
							cell.creditHeadingLabel.text = "Credits purchase"
							cell.thumbnailImageView.backgroundColor = UIColor.greenColorCA().colorWithAlphaComponent(0.8)
							cell.thumbnailLabel.text = "C"
							if let amount = data[indexPath.row-1]["AMOUNT"] as? String{
								var text = "credit"
								if Int(amount)! > 1{
									text = "credits"
								}
						  cell.creditLabel.text = "+"+"\(amount) \(text)"
							}
						}
					}
					if let balance = data[indexPath.row-1]["BALANCE"] as? String{
						cell.creditBalanceLabel.text = "Balance: "+"\(balance)"+" credits"
					}
					printDebug("data[indexPath.row-1] \(data[indexPath.row-1])")
					if let date = data[indexPath.row-1]["CREATED_AT"] as? String{
						let localFormatter: NSDateFormatter = NSDateFormatter()
						localFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
						
						localFormatter.timeZone = NSTimeZone.localTimeZone()
						printDebug("date \(date)")
						if let localDate  = localFormatter.dateFromString(date){
							localFormatter.dateFormat = "MMM dd, yyyy"
							
							let createdAt = localFormatter.stringFromDate(localDate)
							
							printDebug("currentDate \(createdAt)")
							
							cell.creditTimeLabel.text = createdAt
						}
						cell.selectionStyle = .None
						return cell
					}
				}
				
			}
		}
		return UITableViewCell()
		
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		
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
	
	func fetchUserCreditBalance(){
		
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			var params = [RequestParam(key: "teacher", value: "true")]
			params.append(RequestParam(key: "email", value: email))
			do{
				let response = try ServerInterface.callSync(PHPAction.USER_CREDIT_BALANCE, params: params, jsonType: .JSONObject)
				
				if let data = response.jsonObject?["success"] as? JSONObject{
					printDebug("data \(data)")
					userBalance = data
					runOnUIThread({
						self.loadTableView()
					})
					
				}
			}
			catch{
				Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
				
				printDebug("error")
			}
		}
		
	}
	
	func fetchCreditPriceListFromServer(){
		
		if let email = Prefs.stringForKey(Prefs.KEY_USER_EMAIL){
			var params = [RequestParam(key: "teacher", value: "true")]
			params.append(RequestParam(key: "email", value: email))
			do{
				let response = try ServerInterface.callSync(PHPAction.USER_CREDIT_HISTORY, params: params, jsonType: .JSONObject)
				
				if let data = response.jsonObject?["success"] as? JSONArray{
					printDebug("data \(data)")
					self.data = data
					runOnUIThread({
						if self.downloadIndicator.isAnimating(){
							self.downloadIndicator.stopAnimating()
							self.loadTableView()
						}
						
					})
					
				}else{
					Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
					
				}
			}
			catch{
				Toast.makeToastWithLocalizedText("downloadable_lesson_download_failed_network", duration: .Small)
				
				printDebug("error")
			}
		}
		
	}
}
