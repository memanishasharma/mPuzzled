//
//  Teacher+CoreDataProperties.swift
//  Hello English
//
//  Created by Manisha on 24/05/17.
//  Copyright © 2017 CultureAlley. All rights reserved.
//

import Foundation
import CoreData


extension ChatTeacher {

    @NSManaged var id: String?
    @NSManaged var data: NSObject?
    @NSManaged var sessionId: String?
    @NSManaged var status: String?
    @NSManaged var teacher_email: String?
    @NSManaged var teacher_id: String?
    @NSManaged var time: String?
    @NSManaged var sender: String?

}
