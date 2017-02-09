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
    static var viewBackgroundColor = UIColor(colorLiteralRed: (200/255), green: (212/255), blue: (226/255), alpha: 1.0)
    static var labelFont = UIFont(name: "HelveticaNeue", size: 17)
    static var mainLabelFont = UIFont(name: "HelveticaNeue", size: 35)!
    static var warningLabelColor = UIColor.red
    
    
    static func styleDark(){
        labelColor = UIColor.white
        viewBackgroundColor = UIColor(colorLiteralRed: (44/255), green: (47/255), blue: (50/255), alpha: 1.0)
    }
    
    static func styleLight(){
        labelColor = UIColor.black
        viewBackgroundColor = UIColor(colorLiteralRed: (200/255), green: (212/255), blue: (226/255), alpha: 1.0)
    }

}
