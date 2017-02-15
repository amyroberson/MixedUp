//
//  Location+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var id: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var state: String?
    @NSManaged public var stateAbbr: String?
    @NSManaged public var street: String?
    @NSManaged public var streetNum: String?
    @NSManaged public var town: String?
    @NSManaged public var zipCode: Int32
    @NSManaged public var zipExp: Int32
    @NSManaged public var bar: Bar?

}
