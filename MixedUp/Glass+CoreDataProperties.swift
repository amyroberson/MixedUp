//
//  Glass+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Glass {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Glass> {
        return NSFetchRequest<Glass>(entityName: "Glass");
    }

    @NSManaged public var name: String?
    @NSManaged public var displayName: String?
    @NSManaged public var id: String?
    @NSManaged public var drink: Drink?

}
