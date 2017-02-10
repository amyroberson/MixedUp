//
//  DrinkDetailViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/9/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DrinkDetailViewController: UIViewController {
    
    var coreDataStack: CoreDataStack? = nil
    var drinkStore: DrinkService? = nil
    var userStore: UserService? = nil
    var user: User? = nil
    var defaults: UserDefaults? = nil
    var drink: Drink? = nil
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var glassLabel: UILabel!
    @IBOutlet weak var drinkDescriptionLabel: UILabel!
    
    @IBOutlet weak var toolsLabel: UILabel!
    @IBOutlet weak var ingredientStackView: UIStackView!
    
    @IBOutlet weak var drinkImage: UIImageView!
    @IBOutlet weak var toolsStack: UIStackView!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    
    @IBOutlet weak var addedSuccesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLabels()
        setUpStackViews()
        if let drink = drink {
            if (user?.favoriteDrinks?.contains(drink))!{
                addToFavoritesButton.isEnabled = false
            }
        }
        self.view.backgroundColor = Theme.viewBackgroundColor
        addedSuccesLabel.isHidden = true
        
        if let glassType = drink?.glass?.name {
            switch glassType {
            case "highball":
                drinkImage.image = UIImage(named: "BaseHighBallWithStraw")
            case "huricane":
                drinkImage.image = UIImage(named: "BaseHuricane")
            case "lowball":
                drinkImage.image = UIImage(named: "BaseLowballGarnish")
            case "martini":
                drinkImage.image = UIImage(named: "BaseMartini")
            case "shot":
                drinkImage.image = UIImage(named: "BaseshotGlass")
            case "wineGlass":
                drinkImage.image = UIImage(named: "WineGlass")
            case "ChampagneGlass":
                drinkImage.image = UIImage(named: "ChampagneGlass")
            default:
                drinkImage.image = UIImage(named: "BaseMartiniSweet")
            }
        }
    }
    
    
    @IBAction func addToFavoritesTapped(_ sender: UIButton) {
        if let drink = drink , let user = user, let favorites = user.favoriteDrinks{
            
            user.favoriteDrinks = (favorites.adding(drink) as NSSet)
            addedSuccesLabel.isHidden = false
        }
    }
    
    func setUpStackViews(){
        if let tools = drink?.tools{
            for tool in tools {
                let theToolLabel: UILabel = UILabel()
                theToolLabel.text = (tool as! Tool).displayName ?? ""
                theToolLabel.textColor = Theme.labelColor
                theToolLabel.font = Theme.labelFont
                toolsStack.addSubview(theToolLabel)
            }
        } else {
            let theToolLabel: UILabel = UILabel()
            theToolLabel.text = "No Tools Required!"
            theToolLabel.textColor = Theme.labelColor
            theToolLabel.font = Theme.labelFont
            toolsStack.addSubview(theToolLabel)
        }
        if let ingredients = drink?.ingredients{
            for ingredient in ingredients {
                let theingredientLabel: UILabel = UILabel()
                theingredientLabel.text = (ingredient as! Ingredient).displayName ?? ""
                theingredientLabel.textColor = Theme.labelColor
                theingredientLabel.font = Theme.labelFont
                ingredientStackView.addSubview(theingredientLabel)
            }
        } else {
            let theingredientLabel: UILabel = UILabel()
            theingredientLabel.text = "No Tools Required!"
            theingredientLabel.textColor = Theme.labelColor
            theingredientLabel.font = Theme.labelFont
            ingredientStackView.addSubview(theingredientLabel)
        }
    }
    
    func setUpLabels(){
        displayNameLabel.text = drink?.displayName
        displayNameLabel.textColor = Theme.labelColor
        displayNameLabel.font = Theme.labelFont
        ingredientsLabel.text = "Ingredients:"
        ingredientsLabel.textColor = Theme.labelColor
        ingredientsLabel.font = Theme.labelFont
        let glass = drink?.glass?.displayName
        glassLabel.text = "Served in a \(glass ?? "HighBall Glass") "
        glassLabel.textColor = Theme.labelColor
        glassLabel.font = Theme.labelFont
        drinkDescriptionLabel.text = drink?.stringDescription
        drinkDescriptionLabel.textColor = Theme.labelColor
        drinkDescriptionLabel.font = Theme.labelFont
        toolsLabel.text = "Tools:"
        toolsLabel.textColor = Theme.labelColor
        toolsLabel.font = Theme.labelFont
        addedSuccesLabel.textColor = Theme.labelColor
        addedSuccesLabel.font = Theme.labelFont
    }
    
    
}
