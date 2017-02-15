//
//  Color+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Color {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Color> {
        return NSFetchRequest<Color>(entityName: "Color");
    }

    @NSManaged public var alpha: Int16
    @NSManaged public var blue: Int16
    @NSManaged public var displayName: String?
    @NSManaged public var green: Int16
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var red: Int16
    @NSManaged public var drink: NSSet?

}

// MARK: Generated accessors for drink
extension Color {

    @objc(addDrinkObject:)
    @NSManaged public func addToDrink(_ value: Drink)

    @objc(removeDrinkObject:)
    @NSManaged public func removeFromDrink(_ value: Drink)

    @objc(addDrink:)
    @NSManaged public func addToDrink(_ values: NSSet)

    @objc(removeDrink:)
    @NSManaged public func removeFromDrink(_ values: NSSet)

}
