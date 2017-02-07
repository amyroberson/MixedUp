//
//  Glass+CoreDataClass.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

@objc(Glass)
public class Glass: NSManagedObject {
    static var entityName: String {
        return "Glass"
    }
    
    func toDictionary() -> [String : Any?] {
        let dictionary: [String : Any?] = [
            "name" : self.name,
            "displayName": self.displayName,
            "id" : self.id
        ]
        return dictionary
    }
}
