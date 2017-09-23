//
//  MysteryListViewController.swift
//  M Puzzled
//
//  Created by Manisha on 09/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MysteryListViewController:UIViewController{
	let reuseIdentifier = "Cell"
	var puzzleData:[PuzzleData] = [PuzzleData]()
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var topCardBg: UIView!
	@IBOutlet var closeView: UIView!
	@IBOutlet var listContainerView: UIView!
	
	@IBOutlet var headingLabel: UILabel!
	
	var heading:String = ""
	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView!.register(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
		topCardBg.drawBorder()
		topCardBg.dropShadow()
		closeView.drawBorder()
		closeView.dropShadow()
		listContainerView.drawBorder()
		listContainerView.dropShadow()
		headingLabel.text = heading
		DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
			let context = CoreDataStack.sharedInstance.managedObjectContextMain
			
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PuzzleData")
			do{
				if let data = try context.fetch(fetchRequest) as? [PuzzleData]{
					self.puzzleData = data
				}
			}catch{
				print("Error in fetching data")
			}
			DispatchQueue.main.async(execute: {
				let imageView = UIImageView(image: UIImage(named: "bg-dark.jpg"))
				imageView.contentMode = UIViewContentMode.scaleAspectFill
				
				self.collectionView!.backgroundView = imageView
				self.collectionView.delegate = self
				self.collectionView.dataSource = self
			})
		})
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
	}
	
	@IBAction func closeDidClick(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

extension MysteryListViewController: UICollectionViewDataSource,UICollectionViewDelegate{
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.puzzleData.count
		
	}
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CircularCollectionViewCell
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
		cell.isUserInteractionEnabled = true
		if let cellData = self.puzzleData[indexPath.row].data as? [String:NSObject] ,let title = cellData["title"] as? String,let id = cellData["id"] as? String{
			cell.id = id
			cell.titleLabel.text = title
		}
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		print("i am selected \(indexPath.row)")
        let containerViewController = ContainerViewController()
		if let cellData = self.puzzleData[indexPath.row].data as? [String:NSObject] {
			containerViewController.puzzleData = cellData
		}
		present(containerViewController, animated: true, completion: nil)
		return true
	}
	
}
