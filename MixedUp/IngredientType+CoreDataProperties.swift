//
//  IngredientType+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension IngredientType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IngredientType> {
        return NSFetchRequest<IngredientType>(entityName: "IngredientType");
    }

    @NSManaged public var displayName: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var ingredient: NSSet?

}

// MARK: Generated accessors for ingredient
extension IngredientType {

    @objc(addIngredientObject:)
    @NSManaged public func addToIngredient(_ value: Ingredient)

    @objc(removeIngredientObject:)
    @NSManaged public func removeFromIngredient(_ value: Ingredient)

    @objc(addIngredient:)
    @NSManaged public func addToIngredient(_ values: NSSet)

    @objc(removeIngredient:)
    @NSManaged public func removeFromIngredient(_ values: NSSet)

}
