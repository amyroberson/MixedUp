//
//  User+CoreDataClass.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    static var entityName: String {
        return "User"
    }
}
