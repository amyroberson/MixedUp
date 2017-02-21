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
    var glassStore: GlassService? = nil
    var colorStore: ColorService? = nil
    var toolStore: ToolService? = nil
    var user: User? = nil
    let userIDKey = "userID"
    var typeStore: TypeService? = nil
    
    @IBOutlet weak var mustBeLabel: UILabel!
    @IBOutlet weak var pleaseEnterLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    
    @IBAction func enterPressed(_ sender: UIButton) {
        let today = Date()
        let twentyOneYearsAgo = Calendar.current.date(byAdding: .year, value: -21, to: today)
        if birthdayPicker.date > twentyOneYearsAgo!{
            mustBeLabel.isHidden = false
        } else {
            let user1 = NSEntityDescription.insertNewObject(forEntityName: User.entityName,
                                                            into: (coreDataStack?.privateQueueContext)!) as! User
            user1.id = UUID().uuidString
            self.user = user1
            let result = (userStore?.createCoreDataUser(newUser: user1, inContext: (coreDataStack?.mainQueueContext)!))!
            switch result{
            case .success(let user):
                self.user = user
                self.defaults?.set(user.id, forKey: userIDKey)
            default:
                print("error creating user")
                self.user = user1
            }
            
            if self.user == nil{
                self.user = user1
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: .main)
            let tabsVC = storyBoard.instantiateViewController(withIdentifier: "Tabs") as! TabsViewController
            tabsVC.defaults = defaults
            tabsVC.coreDataStack = coreDataStack
            tabsVC.userStore = userStore
            tabsVC.ingredientStore = ingredientStore
            tabsVC.drinkStore = drinkStore
            tabsVC.user = user
            tabsVC.typeStore = typeStore
            tabsVC.glassStore = glassStore
            tabsVC.colorStore = colorStore
            tabsVC.toolStore = toolStore
            self.show(tabsVC, sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mustBeLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults?.string(forKey: Theme.themeKey) == Theme.lightKey{
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

