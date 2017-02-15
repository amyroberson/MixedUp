//
//  MartiniWithUmbrella.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class MartiniWithUmbrella: UIView {

    var color: UIColor = UIColor.clear
    
    override func draw(_ rect: CGRect) {
        StyleKitGlasses.drawMartiniWithUmbrella(frame: rect, liquid: color)
    }
    
}
