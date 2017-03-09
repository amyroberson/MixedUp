//
//  AppDelegate.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let screen = UIScreen.main
    var window: UIWindow?
    let defaults = UserDefaults.standard
    let userIDKey = "userID"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        defaults.register(defaults: [userIDKey : ""])
        defaults.register(defaults: [Theme.themeKey: Theme.lightKey])
        defaults.set(Theme.lightKey, forKey: Theme.themeKey)
        let coreDataStack = CoreDataStack(modelName: "MixedUpDataModel")
        let userStore = UserService(coreDataStack)
        let ingredientStore = IngredientService(coreDataStack)
        let drinkStore = DrinkService(coreDataStack)
        let typeStore = TypeService(coreDataStack)
        let toolStore = ToolService(coreDataStack)
        let glassStore = GlassService(coreDataStack)
        let colorStore = ColorService(coreDataStack)
        var user: User? = nil
        
        if let userIDString = defaults.string(forKey: userIDKey), userIDString.isEmpty == false{
            let tempUser = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                               into: coreDataStack.privateQueueContext) as! User
            tempUser.id = userIDString
            let result = (userStore.fetchUser(user: tempUser, inContext: coreDataStack.mainQueueContext))
            switch result{
            case .success(let cDUser):
                user = cDUser
            default:
                print("error user was not created")
            }
        }
        
        if user != nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "Tabs") as! TabsViewController
            initialViewController.defaults = defaults
            initialViewController.coreDataStack = coreDataStack
            initialViewController.userStore = userStore
            initialViewController.ingredientStore = ingredientStore
            initialViewController.drinkStore = drinkStore
            initialViewController.user = user
            initialViewController.typeStore = typeStore
            initialViewController.glassStore = glassStore
            initialViewController.colorStore = colorStore
            initialViewController.toolStore = toolStore
            window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
            //show age picker, to be able to create new use
        } else if user == nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "Birthday") as! BirthdayViewController
            initialViewController.defaults = defaults
            initialViewController.coreDataStack = coreDataStack
            initialViewController.userStore = userStore
            initialViewController.ingredientStore = ingredientStore
            initialViewController.drinkStore = drinkStore
            initialViewController.typeStore = typeStore
            initialViewController.glassStore = glassStore
            initialViewController.colorStore = colorStore
            initialViewController.toolStore = toolStore
            window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        return true
    }
}

