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
    var coreDataStack = CoreDataStack(modelName: "MixedUpDataModel")
    var userStore: UserService? = nil
    var ingredientStore: IngredientService? = nil
    var drinkStore: DrinkService? = nil
    var user: User? = nil
    let userID = "userID"
    var typeStore: TypeService? = nil
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        defaults.register(defaults: ["Over21": false])
        defaults.register(defaults: [userID : ""])
        defaults.register(defaults: ["theme": "Light"])
        userStore = UserService(coreDataStack)
        ingredientStore = IngredientService(coreDataStack)
        drinkStore = DrinkService(coreDataStack)
        typeStore = TypeService(coreDataStack)
        
        if let userIDString = defaults.string(forKey: userID), userIDString.isEmpty == false{
            
            let tempUser = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                               into: coreDataStack.privateQueueContext) as! User
            tempUser.id = userIDString
            
            let result = (userStore?.fetchUser(user: tempUser, inContext: coreDataStack.mainQueueContext))!
            switch result{
            case .success(let user):
                self.user = user
            default:
                print("error user was not created")
                //needs to be handled differently or throw
            }
        }
        
        if user != nil {
            // pass user on to the rest of the app
            //but for now the user is waiting
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
            
            window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
        } else if user == nil {
            //show age picker
            //to be able to create new user
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "Birthday") as! BirthdayViewController
            initialViewController.defaults = defaults
            initialViewController.coreDataStack = coreDataStack
            initialViewController.userStore = userStore
            initialViewController.ingredientStore = ingredientStore
            initialViewController.drinkStore = drinkStore
            initialViewController.typeStore = typeStore
            
            window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if screen.brightness > 0.4 {
            print("Light")
            defaults.set("Light", forKey: "theme")

        } else {
            print("Dark")
            defaults.set("Dark", forKey: "theme")
        }

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

