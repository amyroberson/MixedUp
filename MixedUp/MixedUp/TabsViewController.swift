//
//  TabsViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class TabsViewController: UITabBarController {
    
    var defaults: UserDefaults? = nil
    var coreDataStack: CoreDataStack? = nil
    var userStore: UserService? = nil
    var ingredientStore: IngredientService? = nil
    var drinkStore: DrinkService? = nil
    var toolStore: ToolService? = nil
    var glassStore: GlassService? = nil
    var colorStore: ColorService? = nil
    var user: User? = nil
    var typeStore: TypeService? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .black
        tabBar.items?[0].title = "Recipes"
        tabBar.items?[1].title = "Inventory"
        tabBar.items?[2].title = "Favorites"
        tabBar.items?[3].title = "Make These"
        tabBar.items?[4].title = "Create Drink"
        for item in self.viewControllers!{
            if let controller = item as? UINavigationController{
                if let iBAVC = controller.topViewController as? IBAViewController{
                    iBAVC.coreDataStack = coreDataStack
                    iBAVC.drinkStore = drinkStore
                    iBAVC.userStore = userStore
                    iBAVC.user = user
                    iBAVC.defaults = defaults
                } else if let inventoryVC = controller.topViewController as? InventoryTableViewController {
                    inventoryVC.coreDataStack = coreDataStack
                    inventoryVC.ingredientStore = ingredientStore
                    inventoryVC.user = user
                    inventoryVC.userStore = userStore
                    inventoryVC.typeStore = typeStore
                    inventoryVC.defaults = defaults
                } else if let favoriteVC = controller.topViewController as? FavoritesViewController {
                    favoriteVC.defaults = defaults
                    favoriteVC.coreDataStack = coreDataStack
                    favoriteVC.userStore = userStore
                    favoriteVC.drinkStore = drinkStore
                    favoriteVC.user = user
                 } else if let generatedVC = controller.topViewController as? GeneratedRecipesViewController {
                    generatedVC.defaults = defaults
                    generatedVC.coreDataStack = coreDataStack
                    generatedVC.userStore = userStore
                    generatedVC.drinkStore = drinkStore
                    generatedVC.user = user
                } else if let pickerVC = controller.topViewController as? GlassPickerViewController {
                    pickerVC.defaults = defaults
                    pickerVC.coreDataStack = coreDataStack
                    pickerVC.userStore = userStore
                    pickerVC.ingredientStore = ingredientStore
                    pickerVC.toolStore = toolStore
                    pickerVC.glassStore = glassStore
                    pickerVC.colorStore = colorStore
                    pickerVC.user = user
                    pickerVC.typeStore = typeStore
                    pickerVC.drinkStore = drinkStore
                }
            }
        }
        
    }
    
    
}
