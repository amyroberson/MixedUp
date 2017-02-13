//
//  Util.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData


enum ResourceResult<A> {
    case success(A)
    case sucess(Bool)
    case failure(Errors)
    case fail(NSError)
    
}

enum Errors: Swift.Error{
    case http(HTTPURLResponse)
    case system(Swift.Error)
    case resource(Util.Error)
    case invalidJSONData
    case inValidParameter
    case failedToSave
    
}

struct Util {
    internal enum Error: Swift.Error {
        case invalidJSONData
        
    }
}

