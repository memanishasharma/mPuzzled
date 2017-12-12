//
//  HomeScreenViewController.swift
//  M Puzzled
//
//  Created by Manisha on 14/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import UIKit

class HomeScreenViewController: UIViewController{
	
	@IBOutlet var tableView: UITableView!
	
	var members: [HomeItem] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.backgroundView = UIImageView(image:UIImage(named:"background"))
		self.tableView.estimatedRowHeight = 280
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.delegate = self
		self.tableView.dataSource = self
		loadModel()
	}
	
	func loadModel() {
		let path = Bundle.main.url(forResource: "home_item_list", withExtension: "json")
		members = HomeItem.loadMembersFromFile(path!)
	}
}


extension HomeScreenViewController: UITableViewDelegate,UITableViewDataSource{
	// Mark: - Table View
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		TableScrollCellAnimator.animate(cell)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return members.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Card", for: indexPath) as! HomeItemCell
		let member = members[indexPath.row]
		cell.useMember(member)
		
		switch indexPath.row % 6 {
		case 0:
			cell.cardBg.backgroundColor = UIColor.FlatColor.materialColor.C3
			cell.mainView.backgroundColor = UIColor.FlatColor.materialColor.C3.withAlphaComponent(0.6)
			break
		case 1:
			cell.cardBg.backgroundColor = UIColor.FlatColor.materialColor.GreenSea
			cell.mainView.backgroundColor = UIColor.FlatColor.materialColor.GreenSea.withAlphaComponent(0.6)
			break
			
		case 2:
			cell.cardBg.backgroundColor = UIColor.FlatColor.materialColor.C1
			cell.mainView.backgroundColor = UIColor.FlatColor.materialColor.C1.withAlphaComponent(0.6)
			break
			
		case 3:
			cell.cardBg.backgroundColor = UIColor.FlatColor.materialColor.BelizeHole
			cell.mainView.backgroundColor = UIColor.FlatColor.materialColor.BelizeHole.withAlphaComponent(0.6)
			break
		case 4:
			cell.cardBg.backgroundColor = UIColor.FlatColor.materialColor.Turquoise
			cell.mainView.backgroundColor = UIColor.FlatColor.materialColor.Turquoise.withAlphaComponent(0.6)
			break
		case 5:
			cell.cardBg.backgroundColor = UIColor.FlatColor.materialColor.Alizarin
			cell.mainView.backgroundColor = UIColor.FlatColor.materialColor.Alizarin.withAlphaComponent(0.6)
			break
		default:
			break
		}
		cell.mainView.drawBorder()
		cell.cardBg.drawBorder()
		cell.cardBg.dropShadow()
	    cell.iconImageView.image = cell.iconImageView.image!.withRenderingMode(.alwaysTemplate)
		cell.iconImageView.tintColor = UIColor.white
		cell.iconImageView.image = UIImage(named: "glassPNG")
		return cell
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		let cell = self.tableView.cellForRow(at: indexPath) as! HomeItemCell
		
		if cell.nameLabel.text == "MYSTERY SOLVER"{
			let storyboard = UIStoryboard(name: "Mystery", bundle: nil)
			if let viewController = storyboard.instantiateViewController(withIdentifier: "MysteryListViewController") as? MysteryListViewController {
				viewController.heading = cell.nameLabel.text!
				
				present(viewController, animated: true, completion: nil)
			}
		}else if cell.nameLabel.text == "TIME PASSER"{
			let storyboard = UIStoryboard(name: "TimePasser", bundle: nil)
			if let viewController = storyboard.instantiateViewController(withIdentifier: "TimePasserViewController") as? TimePasserViewController {
				present(viewController, animated: true, completion: nil)
			}
		}else if cell.nameLabel.text == "REACH CENTER"{
			let storyboard = UIStoryboard(name: "ReachCenter", bundle: nil)
			if let viewController = storyboard.instantiateViewController(withIdentifier: "CircleCenterGameViewController") as? CircleCenterGameViewController {
				present(viewController, animated: true, completion: nil)
			}
		}
			//		}else if cell.nameLabel.text == "WORD GEEK"{
			//			let storyboard = UIStoryboard(name: "CrossWord", bundle: nil)
			//			if let viewController = storyboard.instantiateViewController(withIdentifier: "WordCrossWordViewController") as? WordCrossWordViewController {
			//				present(viewController, animated: true, completion: nil)
			//			}
			//		}
			
			return nil
		}
}
