//
//  TeacherOptionPickViewController.swift
//  Hello English
//
//  Created by Manisha on 17/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation

class TeacherOptionPickViewController:CAViewController,UITableViewDataSource,UITableViewDelegate{
	
	@IBOutlet var backButton: UIButton!
	
	@IBOutlet var navBarHeadingLabel: UILabel!
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var downloadIndicator: UIActivityIndicatorView!
	
	var type :String = ""
	var popToViewController: UIViewController!
	var listData:[[String:NSObject]]?
	
	var timeDataMap:[[String:NSObject]]?
	var datelist = [String]()
	var isCalledAgain = false
	var selectedDate = ""
	
	
	override func viewDidLoad(){
	  super.viewDidLoad()
		backButton.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
		
		
		if type == TeacherOptionPickerType.BUY_CREDIT.rawValue{
		navBarHeadingLabel.text = "Buy Credits"
		}else if  type == TeacherOptionPickerType.SHOW_SLOT.rawValue{
			navBarHeadingLabel.text = "Pick a Date"
		}else{
			navBarHeadingLabel.text = ""
		}
		runOnUIThread({
			self.downloadIndicator.startAnimating()
		})
	}
	
	override func viewWillAppear(animated:Bool){
		super.viewWillAppear(animated)
		self.timeDataMap = [[String:NSObject]]()
		self.optionType()
		
	}
	
	func loadTable(){
		runOnUIThread({
			if self.downloadIndicator.isAnimating(){
				self.downloadIndicator.stopAnimating()
			}
			self.tableView.dataSource = self
			self.tableView.delegate = self
			self.tableView.estimatedRowHeight = 100.0
			self.tableView.reloadData()
		})
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if type == TeacherOptionPickerType.BUY_CREDIT.rawValue ,let data = listData{
			return data.count
		}else if  type == TeacherOptionPickerType.SHOW_SLOT.rawValue{
			return self.datelist.count
		}
		return 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if let cell = self.tableView.dequeueReusableCellWithIdentifier("TeacherOptionCell") as? TeacherCell{
		if let data = listData{
			 let item = data[indexPath.row]
			if type == TeacherOptionPickerType.BUY_CREDIT.rawValue{
				let credit = item["credit"] as? Int
				if let locationCountry = Prefs.stringForKey(Prefs.KEY_LOCATION_COUNTRY){
					if locationCountry == "India"{
						let price = item["india_price"] as? Float
						if let _price = price ,let _credit = credit{
						   cell.optionLabel.text = "Buy"+" "+"\(_credit)"+" "+"Credits for "+"Rs"+" "+"\(_price)"
						}
					}else{
						let price = item["other_price"] as? Float
						if let _price = price ,let _credit = credit{
							let dolar: String = "\u{0024}"
							cell.optionLabel.text = "Buy"+" "+"\(_credit)"+" "+"Credits for "+" "+"\(_price)"+" "+"\(dolar)"
						}
					}
					
				}else{
					let price = item["other_price"] as? Float
					if let _price = price ,let _credit = credit{
						let dolar: String = "\u{0024}"
						cell.optionLabel.text = "Buy"+" "+"\(_credit)"+" "+"Credits for "+" "+"\(_price)"+" "+"\(dolar)"
					}
				}
				
			}else if  type == TeacherOptionPickerType.SHOW_SLOT.rawValue{
				
				let item = self.datelist[indexPath.row]
				cell.optionLabel.text = item
				cell.optionImageView.image = UIImage(named: "ic_radio_button_unchecked_black_24dp")
				
			}
			
			return cell
		}
		}
		return UITableViewCell()
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		
	}
	
	func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if type == TeacherOptionPickerType.SHOW_SLOT.rawValue{
			if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? TeacherCell{
				cell.optionImageView.image = UIImage(named: "ic_radio_button_checked")
			}
		}
		return indexPath
	}
	
	
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if type == TeacherOptionPickerType.BUY_CREDIT.rawValue{
			performSegueWithIdentifier("buyCredit", sender: self)
		}else if type == TeacherOptionPickerType.SHOW_SLOT.rawValue{
			//controller.selectedDate = datelist[indexPath.row]
			let selectedDate = datelist[indexPath.row]
			var array:[[String:NSObject]] = [[String:NSObject]]()
				if let timeData = self.timeDataMap{
					for i in 0..<timeData.count{
						if timeData[i]["day"] == selectedDate{
							if let data = timeData[i]["timeGap"] as? String,let compDate = timeData[i]["completData"] as? [String:NSObject],let date = timeData[i]["day"] as? String{
								var dictData = [String:NSObject]()
								dictData["completData"] = compDate
								dictData["timeGap"] = data
								dictData["date"] = date
								array.append(dictData)
							}
						}
					}
					
					let storyBoard = UIStoryboard(name:"Teacher",bundle: nil)
					if let viewController = storyBoard.instantiateViewControllerWithIdentifier(TeacherSessionTimerListController.nameOfClass) as? TeacherSessionTimerListController{
						viewController.popToViewController = self
						viewController.listData = array
						viewController.rootViewController = self.popToViewController
						self.navigationController?.pushViewController(viewController, animated: true)
					}
				}
			
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
	
	
	func optionType(){
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		
		dispatch_async(queue) { () -> Void in
			if self.type == TeacherOptionPickerType.BUY_CREDIT.rawValue{
				   self.fetchCreditPriceListFromServer()
			}else if self.type == TeacherOptionPickerType.SHOW_SLOT.rawValue{
				if !self.isCalledAgain{
			       self.fetchSessionListFromServer()
				}else{
					self.loadTable()
				}
			}
		}
	}
	
	
	func fetchSessionListFromServer(){
		if let response = TeacherServerMethodCalls.fetchSessionTimeFromServer(){
			if  response.count != 0{
				self.listData = response
				
				if let data = self.listData{
				for i in 0..<data.count{
					if var startTime = data[i]["start"] as? String, var endTime  = data[i]["end"] as? String{
						if let time = TeacherCommonClass.getLocalTimeString(startTime){
							startTime = time
						}
						if let time = TeacherCommonClass.getLocalTimeString(endTime){
							endTime = time
						}
						
						if let date = TeacherCommonClass.getDate(startTime),let timeGap = TeacherCommonClass.getHoursAndMinute(startTime,endTime:endTime){
							var dataToBeMapped = [String:NSObject]()
							dataToBeMapped["completData"] = data[i] 
							dataToBeMapped["day"] = date
							dataToBeMapped["timeGap"] = timeGap 
							timeDataMap?.append(dataToBeMapped)
						}
						
						var arrayValue = [String]()
						if let data = timeDataMap{
							for item in data{
								
								if let _date = item["day"] as? String{
									if arrayValue.contains(_date){
										continue
									}else{
										arrayValue.append(_date)
									}
								}
							}
						}
						
						datelist = arrayValue
						loadTable()

					}
				}
			  }
		   }
		}
    }

	
	func fetchCreditPriceListFromServer(){
		let params = [RequestParam(key: "payments", value: "true")]
		do{
			let response = try ServerInterface.callSync(PHPAction.GET_CREDIT_PRICE_LIST, params: params, jsonType: .JSONObject)
			
			if let data = response.jsonObject?["success"] as? JSONArray{
				self.listData = data
				loadTable()
           }
		}catch{
			printDebug("error")
		}

	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let viewController = segue.destinationViewController as? TeacherPurchaseCreditController{
			
			if let indexPath = self.tableView.indexPathForSelectedRow{
				if let data = listData{
					let item = data[indexPath.row]
					viewController.data = item
					viewController.popToViewController = self
					viewController.rootViewController = self.popToViewController
				}
			}
		}
	}
	
	
	
}
