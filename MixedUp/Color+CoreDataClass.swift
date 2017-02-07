//
//  Color+CoreDataClass.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData

@objc(Color)
public class Color: NSManagedObject {

    static var entityName: String {
        return "Color"
    }
    
    func toDictionary() -> [String: Any] {
        let dictionary: [String: Any?] = [
            "displayName" : self.displayName,
            "red" : self.red,
            "green" : self.green,
            "blue" : self.blue,
            "alpha" : self.alpha,
            "id" : self.id,
            "name" : self.name]
        return dictionary
    }
}
