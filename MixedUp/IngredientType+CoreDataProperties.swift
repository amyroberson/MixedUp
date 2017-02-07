//
//  IngredientType+CoreDataProperties.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


extension IngredientType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IngredientType> {
        return NSFetchRequest<IngredientType>(entityName: "IngredientType");
    }

    @NSManaged public var name: String?
    @NSManaged public var displayName: String?
    @NSManaged public var id: String?
    @NSManaged public var ingredient: Ingredient?

}
