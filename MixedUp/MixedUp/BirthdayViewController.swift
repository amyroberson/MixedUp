//
//  ViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit
import CoreData

class BirthdayViewController: UIViewController {
    
    var defaults: UserDefaults? = nil
    var coreDataStack: CoreDataStack? = nil
    var userStore: UserService? = nil
    var ingredientStore: IngredientService? = nil
    var drinkStore: DrinkService? = nil
    var user: User? = nil
    
    @IBOutlet weak var mustBeLabel: UILabel!
    
    @IBOutlet weak var pleaseEnterLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func enterPressed(_ sender: UIButton) {
        let today = Date()
        let twentyOneYearsAgo = Calendar.current.date(byAdding: .year, value: -21, to: today)
        
        if birthdayPicker.date > twentyOneYearsAgo!{
            mustBeLabel.isHidden = false
        } else {
            //create user request
            let user = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                           into: (coreDataStack?.privateQueueContext)!) as! User
            
            userStore?.createUser(user: user, completion: {result in
                switch result{
                case .success(let users):
                    if users.count > 0{
                        self.user = users[0]
                    }
                    print("error creating user")
                default:
                    print("error creating user")
                }
            })
            defaults?.set(true, forKey: "Over21")
            defaults?.set(user.id, forKey: "userID")
            let storyBoard = UIStoryboard(name: "Main", bundle: .main)
            let tabsVC = storyBoard.instantiateViewController(withIdentifier: "Tabs") as! TabsViewController
            tabsVC.defaults = defaults
            tabsVC.coreDataStack = coreDataStack
            tabsVC.userStore = userStore
            tabsVC.ingredientStore = ingredientStore
            tabsVC.drinkStore = drinkStore
            tabsVC.user = user
            self.show(tabsVC, sender: nil)
        }
        
        
    }
    
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mustBeLabel.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults?.string(forKey: "theme") == "Light"{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
        pleaseEnterLabel.textColor = Theme.labelColor
        pleaseEnterLabel.font = Theme.labelFont
        self.view.backgroundColor = Theme.viewBackgroundColor
        headerLabel.textColor = Theme.labelColor
        headerLabel.font = Theme.mainLabelFont
        
    }
    
}

