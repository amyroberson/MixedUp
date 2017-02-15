//
//  Location+CoreDataClass.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

@objc(Location)
public class Location: NSManagedObject {
    static var entityName: String {
        return "Location"
    }
}
