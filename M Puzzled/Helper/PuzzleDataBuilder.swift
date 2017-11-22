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
		if self.isCancelled{
			return
		}
		
		if let file = jsonFileName,let path = Bundle.main.path(forResource: file, ofType: "json"){
			do{
				let data = try Data(contentsOf: URL(fileURLWithPath: path))
				print("dataTr \(data.base64EncodedData())")
				if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:NSObject]{
					print("json ")
					let context = CoreDataStack.sharedInstance.managedObjectContext
					if let puzzleData = json["data"] as? [[String:NSObject]]{
						for item in puzzleData{
							
							if let id = item["id"] as? String{
								let statusOfID = PuzzleData.puzzleDataById(inContext: context, id: id)
								
								if !statusOfID{
									let object = createEntityFrom(dictionary: item,context : context)
									try object?.save()
								}
							}else{
								continue
							}
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

	private func createEntityFrom(dictionary: [String: NSObject],context: NSManagedObjectContext) -> NSManagedObjectContext? {
	
	if let puzzleEntity = NSEntityDescription.insertNewObject(forEntityName: "PuzzleData", into: context) as? PuzzleData {
		puzzleEntity.data = dictionary as NSObject
		puzzleEntity.category = dictionary["category"] as? String
		puzzleEntity.id = dictionary["id"] as? String
		puzzleEntity.type = dictionary["type"] as? String
		return context
	}
	return nil
}
}

