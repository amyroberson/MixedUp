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
    static var themeKey = "theme"
    static var lightKey = "Light"
    static var darkKey = "Dark"
    static var fontKey = "HelveticaNeue"
    static var fontBoldKey = "HelveticaNeue-Bold"
    static var labelColor = UIColor.black
    static var viewBackgroundColor = UIColor(colorLiteralRed: (200/255), green: (212/255), blue: (226/255), alpha: 1.0)
    static var labelFont = UIFont(name: Theme.fontKey, size: 17)!
    static var mainLabelFont = UIFont(name: Theme.fontKey, size: 35)!
    static var warningLabelColor = UIColor.red
    static var cellLabelFont = UIFont(name: Theme.fontKey, size: 13)!
    static var boldLabelFont = UIFont(name: fontBoldKey, size: 19)!
    
    static func styleDark(){
        labelColor = UIColor.black //(colorLiteralRed: (206/255), green: (213/255), blue: (224/255), alpha: 1.0)
        viewBackgroundColor = UIColor(colorLiteralRed: (145/255), green: (153/255), blue: (166/255), alpha: 1.0)
    }
    
    static func styleLight(){
        labelColor = UIColor.black
        viewBackgroundColor = UIColor(colorLiteralRed: (200/255), green: (212/255), blue: (226/255), alpha: 1.0)
    }
}
