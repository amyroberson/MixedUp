//
//  DrawGlass.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

enum Glasses: String {
    case martini = "Martini"
    case highball = "Highball"
    case shot = "Shot"
    case wine = "Wine"
    case lowBall = "LowBall"
    case lowball = "Lowball"
    case hurricane = "Hurricane"
    case champagne = "Champagne"
    case coconut = "Coconut"
    case base = ""
}


class DrawGlass: UIView {
    
    var color: UIColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0){
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    var glass:String = ""{
        didSet {
            setNeedsDisplay()
        }
    }
    
    var descriptionString: String = ""{
        didSet {
            setNeedsDisplay()
        }
    }
    
    let cherryKey = "cherry"
    let oliveKey = "olive"
    let umbrellaKey = "umbrella"
    let strawKey = "straw"
    let garnishKey = "garnish"
    
    override func draw(_ rect: CGRect) {
        let glassEnum = Glasses(rawValue: glass)!
        switch glassEnum {
        case .martini:
            if descriptionString.contains(cherryKey){
                StyleKitGlasses.drawMartiniCherry(frame: rect, liquid: color)
            } else if descriptionString.contains(oliveKey){
                StyleKitGlasses.drawMartiniWithOlive(martiniWithOlive: rect, liquid: color)
            } else  if descriptionString.contains(umbrellaKey){
                StyleKitGlasses.drawMartiniWithUmbrella(frame: rect, liquid: color)
            } else {
                StyleKitGlasses.drawMartini(frame: rect, liquid: color)
            }
        case .highball:
            if descriptionString.contains(strawKey){
                StyleKitGlasses.drawHighBallWithStraw(frame: rect, liquid: color)
            } else if descriptionString.contains(garnishKey){
                StyleKitGlasses.drawHighBallWithLemon(frame: rect, liquid: color)
            } else {
                StyleKitGlasses.drawHighBall(frame: rect, liquid: color)
            }
        case .shot:
            StyleKitGlasses.drawShotGlass(frame: rect, liquid: color)
        case .wine:
            StyleKitGlasses.drawWineGlass(frame: rect, liquid: color)
        case .lowBall, .lowball:
            if descriptionString.contains(garnishKey){
                StyleKitGlasses.drawLowBallWithLemon(frame: rect, liquid: color)
            } else {
                StyleKitGlasses.drawLowBall(frame: rect, liquid: color)
            }
        case .hurricane:
            if descriptionString.contains(garnishKey){
                StyleKitGlasses.drawHurricaneWithUmbrella(frame: rect, liquid: color)
            } else  {
                StyleKitGlasses.drawHurricane(frame: rect, liquid: color)
            }
        case .champagne:
            StyleKitGlasses.drawChampagne(frame: rect, liquid: color)
        case .coconut:
            StyleKitGlasses.drawCoconut(frame: rect, liquid: color)
        default:
            StyleKitGlasses.drawLowBall(frame: rect, liquid: color)
        }
    }
    
}
