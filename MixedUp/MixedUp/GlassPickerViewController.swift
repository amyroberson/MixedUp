//
//  GlassPickerViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class GlassPickerViewController: UIViewController {

    var defaults: UserDefaults? = nil
    var coreDataStack: CoreDataStack? = nil
    var userStore: UserService? = nil
    var ingredientStore: IngredientService? = nil
    var drinkStore: DrinkService? = nil
    var user: User? = nil
    var typeStore: TypeService? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
