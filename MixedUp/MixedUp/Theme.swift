//
//  Theme.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    static var labelColor = UIColor.black
    static var viewBackgroundColor = UIColor.white
    static var labelFont = UIFont(name: "HelveticaNeue", size: 17)
    static var mainLabelFont = UIFont(name: "HelveticaNeue", size: 35)!
    static var warningLabelColor = UIColor.red
    
    
    static func styleDark(){
        labelColor = UIColor.white
        viewBackgroundColor = UIColor.darkGray
    }
    
    static func styleLight(){
        labelColor = UIColor.black
        viewBackgroundColor = UIColor.white
    }

}
