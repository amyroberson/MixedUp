//
//  IngredientType+CoreDataClass.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

@objc(IngredientType)
public class IngredientType: NSManagedObject {
    static var entityName: String {
        return "IngredientType"
    }
    
    
    func toDictionary() -> [String: Any] {
        let keyValuePairs: [(String, Any?)] = [
            ("displayName",  self.displayName),
            ("id", self.id),
            ("name", self.name)]
        
        var dict: [String: Any] = [:]
        
        for (key, optionalValue) in keyValuePairs {
            if let value = optionalValue {
                dict[key] = value
            }
        }
        return dict
    }
}
