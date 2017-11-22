//
//  PuzzleData+CoreDataClass.swift
//  M Puzzled
//
//  Created by Manisha on 18/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//
//

import Foundation
import CoreData


open class PuzzleData: NSManagedObject {
	class func puzzleDataById(inContext context: NSManagedObjectContext, id : String) -> Bool {
		let request = NSFetchRequest<NSFetchRequestResult>()
		request.entity = NSEntityDescription.entity(forEntityName: PuzzleData.nameOfClass, in: context)
		
		let predicate = NSPredicate(format: "id = %@", id)
		request.predicate = predicate
		var status = false
		context.performAndWait({
			do {
				if let puzzleData = ((try context.fetch(request) as? [PuzzleData])){
					
					if puzzleData.count > 0{
						status = true
					}
				}else{
					print("no kid lesson data found")
				}
			} catch {
				print("error: \(error)")
			}
		})
		return status
	}
}
