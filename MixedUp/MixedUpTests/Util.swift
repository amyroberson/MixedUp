//
//  Util.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum ResourceResult<A> {
    case success(A)
    case sucess(Bool)
    case failure(Errors)
    case fail(NSError)
    
    var successValue: A? {
        switch self {
        case .success(let value):
            return value
        case .sucess, .fail, .failure:
            return nil
        }
    }
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
    
    static func searchDrinks(allDrinks:[Drink], searchText: String) -> [Drink]{
        var returning: Set<Drink> = []
        for drink in allDrinks{
            for ingredient in drink.ingredients!{
                if ((ingredient as! Ingredient).displayName?.lowercased().contains(searchText))! {
                    returning.insert(drink)
                    break
                } else if returning.contains(drink){
                    returning.remove(drink)
                }
            }
            if (drink.displayName?.lowercased().contains(searchText))!{
                returning.insert(drink)
            }
        }
        return Array(returning)
    }
    
    static func getDrinkView(drink: Drink) -> UIView {
        switch drink.glass?.displayName ?? ""{
        case "Martini":
            if (drink.stringDescription?.contains("cherry"))!{
                return MartiniWithCherry()
            } else if (drink.stringDescription?.contains("olive"))!{
                return MartiniWithOlive()
            } else  if (drink.stringDescription?.contains("umbrella"))!{
                return MartiniWithUmbrella()
            } else {
                return Martini()
            }
        case "HighBall", "Highball":
            if (drink.stringDescription?.contains("straw"))!{
                return HighBallWithStraw()
            } else if (drink.stringDescription?.contains("garnish"))!{
                return HighBallWithLemon()
            } else {
                return PlainHighBall()
            }
        case "Shot":
            return ShotGlass()
        case "Wine":
            return WineGlass()
        case "LowBall", "Lowball":
            if (drink.stringDescription?.contains("garnish"))!{
                return LowBallWithLemon()
            } else {
                return LowBall()
            }
        case "Hurricane", "Huricane":
            if (drink.stringDescription?.contains("garnish"))!{
                return HurricaneWithUmbrella()
            } else  {
                return Hurricane()
            }
        case "Champagne":
            return Champagne()
        case "Coconut":
            return Coconut()
        default:
            return HighBallWithStraw()
        }
    }
    
}

