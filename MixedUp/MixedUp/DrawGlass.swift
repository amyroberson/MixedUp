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
    case huricane = "Huricane"
    case champagne = "Champagne"
    case coconut = "Coconut"
    case beerGlass = "Beer"
    case beerStein = "Beer Stein"
    case weizen = "Weizen"
    case base = ""
}

class DrawGlass: UIView {
    
    var color: UIColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0){
        didSet {
            setNeedsDisplay()
        }
    }
    
    let lime: UIColor = UIColor(colorLiteralRed: 0.753, green: 0.931, blue: 0.344, alpha: 1)
    let lemon: UIColor = UIColor(colorLiteralRed: 0.958, green: 0.903, blue: 0.327, alpha: 1)
    
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
    let lemonKey = "lemon"
    let limeKey = "lime"
    let garnishKey = "garnish"
    
    override func draw(_ rect: CGRect) {
        let glassEnum = Glasses(rawValue: glass)!
        switch glassEnum {
        case .martini:
            if descriptionString.lowercased().contains(cherryKey){
                StyleKitGlasses.drawMartiniCherry(frame: rect, liquid: color)
            } else if descriptionString.lowercased().contains(oliveKey){
                StyleKitGlasses.drawMartiniWithOlive(martiniWithOlive: rect, liquid: color)
            } else  if descriptionString.lowercased().contains(umbrellaKey){
                StyleKitGlasses.drawMartiniWithUmbrella(frame: rect, liquid: color)
            } else {
                StyleKitGlasses.drawMartini(frame: rect, liquid: color)
            }
        case .highball:
            if descriptionString.lowercased().contains(strawKey){
                StyleKitGlasses.drawHighBallWithStraw(frame: rect, liquid: color)
            } else if descriptionString.lowercased().contains(lemonKey) && descriptionString.lowercased().contains(garnishKey){
                StyleKitGlasses.drawHighBallWithLemon(frame: rect, liquid: color, ganishLabel: lemon)
            }else if descriptionString.lowercased().contains(limeKey){
                StyleKitGlasses.drawHighBallWithLemon(frame: rect, liquid: color, ganishLabel: lime)
            } else {
                StyleKitGlasses.drawHighBall(frame: rect, liquid: color)
            }
        case .shot:
            StyleKitGlasses.drawShotGlass(frame: rect, liquid: color)
        case .wine:
            StyleKitGlasses.drawWineGlass(frame: rect, liquid: color)
        case .lowBall, .lowball:
            if descriptionString.lowercased().contains(lemonKey){
                StyleKitGlasses.drawLowBallWithLemon(frame: rect, liquid: color, ganishLabel: lemon)
            } else  if descriptionString.lowercased().contains(limeKey){
                StyleKitGlasses.drawLowBallWithLemon(frame: rect, liquid: color, ganishLabel: lime)
            } else {
                StyleKitGlasses.drawLowBall(frame: rect, liquid: color)
            }
        case .hurricane, .huricane:
            if descriptionString.lowercased().contains(umbrellaKey){
                StyleKitGlasses.drawHurricaneWithUmbrella(frame: rect, liquid: color)
            } else  {
                StyleKitGlasses.drawHurricane(frame: rect, liquid: color)
            }
        case .champagne:
            StyleKitGlasses.drawChampagne(frame: rect, liquid: color)
        case .coconut:
            StyleKitGlasses.drawCoconut(frame: rect, liquid: color)
        case .beerGlass:
            StyleKitGlasses.drawBeerGlass(frame:  rect, liquid: color)
        case .beerStein:
            StyleKitGlasses.drawBeerStein(frame: rect, liquid: color)
        case .weizen:
            StyleKitGlasses.drawWeizen(frame: rect, liquid: color)
        default:
            StyleKitGlasses.drawLowBall(frame: rect, liquid: color)
        }
    }
}
