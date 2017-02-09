//
//  AppDelegate.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit


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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        defaults.register(defaults: ["Over21": false])
        defaults.register(defaults: ["userID" : ""])
        defaults.register(defaults: ["theme": "Light"])
        userStore = UserService(coreDataStack)
        ingredientStore = IngredientService(coreDataStack)
        drinkStore = DrinkService(coreDataStack)
        
        if defaults.bool(forKey: "over21") && defaults.string(forKey: "userId") != "" {
            userStore?.getUser(id: defaults.string(forKey: "userID") ?? "", completion: {result in
                switch result{
                case .success(let users):
                    if users.count > 0{
                        self.user = users[0]
                    }
                default:
                    print("did not get initial user")
                }
            })
        }
        
        if defaults.bool(forKey: "Over21") {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "Tabs") as! TabsViewController
            initialViewController.defaults = defaults
            initialViewController.coreDataStack = coreDataStack
            initialViewController.userStore = userStore
            initialViewController.ingredientStore = ingredientStore
            initialViewController.drinkStore = drinkStore
            initialViewController.user = user
            
            window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
        } else {
            //show age picker
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "Birthday") as! BirthdayViewController
            initialViewController.defaults = defaults
            initialViewController.coreDataStack = coreDataStack
            initialViewController.userStore = userStore
            initialViewController.ingredientStore = ingredientStore
            
            
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

