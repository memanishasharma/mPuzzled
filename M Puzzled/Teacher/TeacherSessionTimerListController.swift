//
//  TeacherSessionTimerListController.swift
//  Hello English
//
//  Created by Manisha on 26/06/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation


class TeacherSessionTimerListController:CAViewController,UITableViewDataSource,UITableViewDelegate{

	@IBOutlet var backButton: UIButton!
	
	@IBOutlet var navBarHeadingLabel: UILabel!
	
	@IBOutlet var tableView: UITableView!
	
	var popToViewController: UIViewController!
	var rootViewController: UIViewController!
	var listData:[[String:NSObject]]?
	var date:String?

override func viewDidLoad(){
	super.viewDidLoad()
	backButton.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
	navBarHeadingLabel.text = "Pick a Time Slot"
}

override func viewWillAppear(animated:Bool){
	super.viewWillAppear(animated)
	loadTable()
	
	}

func loadTable(){
	runOnUIThread({
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.estimatedRowHeight = 100.0
		self.tableView.reloadData()
	})
}

	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if  let data = self.listData{
			return data.count
		}
		return 0
	}

	
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
	if let cell = self.tableView.dequeueReusableCellWithIdentifier("TeacherOptionCell") as? TeacherCell{
		if let dataItem = self.listData{
			printDebug("listdata \(listData)")
			let item = dataItem[indexPath.row]["timeGap"] as? String
					cell.optionLabel.text = item
					printDebug("item \(item)")
		}
			return cell
		}
	
	return UITableViewCell()
}

func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
	
}

func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
	
	let storyBoard = UIStoryboard(name:"Teacher",bundle: nil)
	if let viewController = storyBoard.instantiateViewControllerWithIdentifier(TeacherSessionBookingViewController.nameOfClass) as? TeacherSessionBookingViewController{
		
		viewController.popToViewController = self
		printDebug("self.listData?[indexPath.row] \(self.listData?[indexPath.row])")
		viewController.slotData = self.listData?[indexPath.row]["completData"] as? [String:NSObject]
		viewController.rootViewController = self.rootViewController
		self.navigationController?.pushViewController(viewController, animated: true)
		
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
}

