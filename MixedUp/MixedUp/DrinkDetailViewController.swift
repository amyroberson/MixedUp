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
    var toolsStack = UIStackView()
    var ingredientStackView = UIStackView()
    var missingIngredientsStack = UIStackView()
    var missingIngredients: [Ingredient] = []
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackViewContainer: UIView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var missingLabel: UILabel!
    @IBOutlet weak var drawDrink: DrawGlass!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var glassLabel: UILabel!
    @IBOutlet weak var drinkDescriptionLabel: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var toolsLabel: UILabel!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var addedSuccesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLabels()
        setUpStackViews()
        mainStackView.insertArrangedSubview(ingredientStackView, at: 5)
        mainStackView.insertArrangedSubview(toolsStack, at: 7)
        mainStackView.insertArrangedSubview(missingIngredientsStack, at: 9)
        if let drink = drink {
            if (user?.favoriteDrinks?.contains(drink))!{
                addToFavoritesButton.setTitle("Remove From Favorites", for: .normal)
            }
        }
        self.view.backgroundColor = Theme.viewBackgroundColor
        addedSuccesLabel.isHidden = true
        addedSuccesLabel.font = Theme.labelFont
        addedSuccesLabel.textColor = Theme.labelColor
        if let color = drink?.color{
            let red = Float(color.red)/255
            let green =  Float(color.green)/255
            let blue =  Float(color.blue)/255
            let alpha: Float =  color.alpha
            drawDrink.color = UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: alpha)
        }
        drawDrink.glass = drink?.glass?.displayName ?? ""
        drawDrink.descriptionString = drink?.description ?? ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if defaults?.string(forKey: Theme.themeKey) == Theme.lightKey{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: self.view.frame.size.width , height: mainStackView.frame.size.height)
    }
    
    @IBAction func addToFavoritesTapped(_ sender: UIButton) {
        if let drink = drink , let user = user, let favorites = user.favoriteDrinks{
            if (user.favoriteDrinks?.contains(drink))! {
                user.removeFromFavoriteDrinks(drink)
                sender.setTitle("Add To Favorites", for: .normal)
                addedSuccesLabel.isHidden = true
            } else {
                user.favoriteDrinks = (favorites.adding(drink) as NSSet)
                addedSuccesLabel.isHidden = false
                sender.setTitle("Remove From Favorites", for: .normal)
            }
            do{
                try coreDataStack?.saveChanges()
            } catch {
                print("did not save drink to user")
            }
        }
    }
    
    func setUpStackViews(){
        let inventory = user?.inventory?.allObjects as! [Ingredient]
        let ingredients = drink?.ingredients?.allObjects as! [Ingredient]
        missingIngredients = Util.getMissingIngredients(inventory, ingredients)
        
        missingIngredientsStack.alignment = .center
        missingIngredientsStack.axis = .vertical
        missingIngredientsStack.setContentHuggingPriority(0.7, for: .vertical)
        missingIngredientsStack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        missingIngredientsStack.distribution = .fill
        
        toolsStack.alignment = .center
        toolsStack.axis = .vertical
        toolsStack.setContentHuggingPriority(0.7, for: .vertical)
        toolsStack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        toolsStack.distribution = .fill
        
        ingredientStackView.alignment = .center
        ingredientStackView.axis = .vertical
        ingredientsLabel.setContentHuggingPriority(0.7, for: .vertical)
        ingredientStackView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        ingredientStackView.distribution = .fill
        if let tools = drink?.tools{
            for tool in tools {
                let theToolLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                theToolLabel.center = CGPoint(x: 160, y: 285)
                theToolLabel.textAlignment = .center
                theToolLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
                theToolLabel.text = (tool as! Tool).displayName ?? ""
                theToolLabel.textColor = Theme.labelColor
                theToolLabel.font = Theme.labelFont
                toolsStack.addArrangedSubview(theToolLabel)
            }
        } else {
            let theToolLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            theToolLabel.center = CGPoint(x: 160, y: 285)
            theToolLabel.textAlignment = .center
            theToolLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
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
                theingredientLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
                theingredientLabel.text = (ingredient as! Ingredient).displayName ?? ""
                theingredientLabel.textColor = Theme.labelColor
                theingredientLabel.font = Theme.labelFont
                ingredientStackView.addArrangedSubview(theingredientLabel)
            }
        } else {
            let theingredientLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            theingredientLabel.center = CGPoint(x: 160, y: 285)
            theingredientLabel.textAlignment = .center
            theingredientLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            theingredientLabel.text = "No ingredients found."
            theingredientLabel.textColor = Theme.labelColor
            theingredientLabel.font = Theme.labelFont
            ingredientStackView.addSubview(theingredientLabel)
        }
        if missingIngredients.count > 0{
            for ingredient in missingIngredients {
                let theingredientLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                theingredientLabel.center = CGPoint(x: 160, y: 285)
                theingredientLabel.textAlignment = .center
                theingredientLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
                theingredientLabel.text = ingredient.displayName ?? ""
                theingredientLabel.textColor = Theme.labelColor
                theingredientLabel.font = Theme.labelFont
                missingIngredientsStack.addArrangedSubview(theingredientLabel)
            }
        } else {
            let theingredientLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            theingredientLabel.center = CGPoint(x: 160, y: 285)
            theingredientLabel.textAlignment = .center
            theingredientLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            theingredientLabel.text = "You have all the ingredients for this drink!"
            theingredientLabel.textColor = Theme.labelColor
            theingredientLabel.font = Theme.labelFont
            missingIngredientsStack.addSubview(theingredientLabel)
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
        missingLabel.font = Theme.boldLabelFont
        missingLabel.textColor = Theme.labelColor
    }
}

