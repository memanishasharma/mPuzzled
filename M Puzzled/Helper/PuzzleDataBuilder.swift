//
//  PuzzleDataBuilder.swift
//  M Puzzled
//
//  Created by Manisha on 18/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import CoreData


class PuzzleDataBuilder: Operation{
	let jsonFileName: String?
	init(jsonFileName:String){
		self.jsonFileName = jsonFileName
	}
	
	override func main(){
		let path = Bundle.main.url(forResource: "modStory", withExtension: "json")
		if self.isCancelled{
			return
		}
		
		if let file = jsonFileName,let path = Bundle.main.url(forResource: file, withExtension: "json"){
			do{
				let data = try Data(contentsOf: path)
				if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:NSObject]{
					if let puzzleData = json["data"] as? [[String:NSObject]]{
						for item in puzzleData{
							let object = createEntityFrom(dictionary: item)
							   try object?.save()
						}
					}else{
						print("vfv ")
					}
				}
			}catch{
				print("eroro \(error)")
			}
		}else{
			print("else in")
		}
	}
	
	private func createEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObjectContext? {
		let context = CoreDataStack.sharedInstance.managedObjectContext
		if let puzzleEntity = NSEntityDescription.insertNewObject(forEntityName: "PuzzleData", into: context) as? PuzzleData {
			let data = dictionary
			puzzleEntity.data = data as? NSObject
			puzzleEntity.category = dictionary["category"] as? String
			puzzleEntity.id = dictionary["id"] as? String
			puzzleEntity.type = dictionary["type"] as? String
			return context
		}
		return nil
	}
}

