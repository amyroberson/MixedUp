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
    var user: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        for item in self.viewControllers!{
            if let controller = item as? UINavigationController{
                if let iBAVC = controller.topViewController as? IBAViewController{
                    iBAVC.coreDataStack = coreDataStack
                    iBAVC.drinkStore = drinkStore
                    iBAVC.userStore = userStore
                    iBAVC.user = user
                }
                
            }
        }

        
        /*
         for item in self.viewControllers!{
         if let controller = item as? UINavigationController{
         if let eventsVC = controller.topViewController as? EventsViewController{
         eventsVC.user = user
         } else if let contactsVC = controller.topViewController as? UserContactsViewController{
         contactsVC.user = user
         } else if let requestVC = controller.topViewController as? RequestsViewController{
         requestVC.user = user
         }
         }
         else if let controller = item as? ProfileViewController{
         controller.user = user
         }
         
         }

        */
    }


}
