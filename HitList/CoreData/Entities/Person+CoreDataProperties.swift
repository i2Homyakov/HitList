//
//  Person+CoreDataProperties.swift
//  HitList
//
//  Created by Max Zasov on 28/07/2019.
//  Copyright © 2019 Max Zasov. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String?

}
