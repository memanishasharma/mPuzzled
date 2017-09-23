//
//  PuzzleData+CoreDataProperties.swift
//  M Puzzled
//
//  Created by Manisha on 18/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//
//

import Foundation
import CoreData


extension PuzzleData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PuzzleData> {
        return NSFetchRequest<PuzzleData>(entityName: "PuzzleData")
    }

    @NSManaged public var id: String?
    @NSManaged public var type: String?
    @NSManaged public var category: String?
    @NSManaged public var data: NSObject?

}
