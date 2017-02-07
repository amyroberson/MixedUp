//
//  Ingredient+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient");
    }

    @NSManaged public var isAlcoholic: Bool
    @NSManaged public var name: String?
    @NSManaged public var displayName: String?
    @NSManaged public var id: String?
    @NSManaged public var type: IngredientType?
    @NSManaged public var drink: Drink?
    @NSManaged public var user: User?
    @NSManaged public var bar: Bar?

}
