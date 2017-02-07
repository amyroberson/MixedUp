//
//  Ingredient+CoreDataClass.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

@objc(Ingredient)
public class Ingredient: NSManagedObject {
    static var entityName: String {
        return "Ingredient"
    }
    
    func toDictionary() -> [String: Any] {
        let dictionary: [String: Any?] = [
            "displayName" : self.displayName,
            "id" : self.id,
            "name" : self.name,
            "isAlcoholic" : self.isAlcoholic,
            "type" : self.type?.toDictionary()]
        return dictionary
    }
}
