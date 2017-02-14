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
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackViewContainer: UIView!
   
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var glassLabel: UILabel!
    @IBOutlet weak var drinkDescriptionLabel: UILabel!
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var toolsLabel: UILabel!
    @IBOutlet weak var drinkImage: UIImageView!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var addedSuccesLabel: UILabel!
    
    var toolsStack = UIStackView()
    var ingredientStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLabels()
        setUpStackViews()
        mainStackView.insertArrangedSubview(ingredientStackView, at: 5)
        mainStackView.insertArrangedSubview(toolsStack, at: 7)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width , height: mainStackView.frame.size.width)
        if let drink = drink {
            if (user?.favoriteDrinks?.contains(drink))!{
                addToFavoritesButton.isEnabled = false
            }
        }
        self.view.backgroundColor = Theme.viewBackgroundColor
        addedSuccesLabel.isHidden = true
        addedSuccesLabel.font = Theme.labelFont
        addedSuccesLabel.textColor = Theme.labelColor
        drinkImage.image = Theme.setImageForDrink(drink: drink!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if defaults?.string(forKey: "theme") == "Light"{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
    }

    
    @IBAction func addToFavoritesTapped(_ sender: UIButton) {
        if let drink = drink , let user = user, let favorites = user.favoriteDrinks{
            
            user.favoriteDrinks = (favorites.adding(drink) as NSSet)
            addedSuccesLabel.isHidden = false
            addToFavoritesButton.isEnabled = false
            do{
                try coreDataStack?.saveChanges()
            } catch {
                print("did not save drink to user")
            }
        }
    }
    
    func setUpStackViews(){
        toolsStack.alignment = .center
        toolsStack.axis = .vertical
        toolsStack.distribution = .equalCentering
        ingredientStackView.alignment = .center
        ingredientStackView.axis = .vertical
        ingredientStackView.distribution = .equalCentering
        if let tools = drink?.tools{
            for tool in tools {
                let theToolLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                theToolLabel.center = CGPoint(x: 160, y: 285)
                theToolLabel.textAlignment = .center
                theToolLabel.text = (tool as! Tool).displayName ?? ""
                theToolLabel.textColor = Theme.labelColor
                theToolLabel.font = Theme.labelFont
                toolsStack.addArrangedSubview(theToolLabel)
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
                let theingredientLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                theingredientLabel.center = CGPoint(x: 160, y: 285)
                theingredientLabel.textAlignment = .center
                theingredientLabel.text = (ingredient as! Ingredient).displayName ?? ""
                theingredientLabel.textColor = Theme.labelColor
                theingredientLabel.font = Theme.labelFont
                ingredientStackView.addArrangedSubview(theingredientLabel)
            }
        } else {
            let theingredientLabel: UILabel = UILabel()
            theingredientLabel.text = "No ingredients found."
            theingredientLabel.textColor = Theme.labelColor
            theingredientLabel.font = Theme.labelFont
            ingredientStackView.addSubview(theingredientLabel)
        }
    }
    
    func setUpLabels(){
        displayNameLabel.text = drink?.displayName
        displayNameLabel.textColor = Theme.labelColor
        displayNameLabel.font = Theme.boldLabelFont
        ingredientsLabel.text = "Ingredients:"
        ingredientsLabel.textColor = Theme.labelColor
        ingredientsLabel.font = Theme.labelFont
        let glass = drink?.glass?.displayName
        glassLabel.text = "Served in a \(glass ?? "HighBall") Glass"
        glassLabel.textColor = Theme.labelColor
        glassLabel.font = Theme.boldLabelFont
        drinkDescriptionLabel.text = drink?.stringDescription
        drinkDescriptionLabel.textColor = Theme.labelColor
        drinkDescriptionLabel.font = Theme.labelFont
        toolsLabel.text = "Tools:"
        toolsLabel.textColor = Theme.labelColor
        toolsLabel.font = Theme.boldLabelFont
        addedSuccesLabel.textColor = Theme.labelColor
        addedSuccesLabel.font = Theme.labelFont
        ingredientsLabel.font = Theme.boldLabelFont
        ingredientsLabel.textColor = Theme.labelColor
        
        
    }
    
    
}

