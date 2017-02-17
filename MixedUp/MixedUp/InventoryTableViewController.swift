//
//  InventoryTableTableViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit
import CoreData

class InventoryTableViewController: UITableViewController {

    var types: [IngredientType] = []
    var coreDataStack: CoreDataStack? = nil
    var ingredientStore: IngredientService? = nil
    var userStore: UserService? = nil
    var user: User? = nil
    var typeStore: TypeService? = nil
    var defaults: UserDefaults? = nil
    var all: IngredientType? = nil
    var type: IngredientType? = nil
   
    
    func setTypes(){
        typeStore?.getAllTypes(completion: {result in
            switch result{
            case .success(let theTypes):
                self.types = theTypes
                self.refresh()
            default:
                print("could not get types")
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTypes()
        self.title = "Inventory"
        view.backgroundColor = Theme.viewBackgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if defaults?.string(forKey: Theme.themeKey) == Theme.lightKey{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
        type = nil
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Type", for: indexPath) as! IngredientTypeCell

        if indexPath.row == 0{
            cell.typeNameLabel.text = "All Ingredients"
            cell.typeNameLabel.textColor = Theme.labelColor
            cell.typeNameLabel.font = Theme.labelFont
            cell.backgroundColor = Theme.viewBackgroundColor
            return cell
        }
        
        let type = types[indexPath.row]
        
        cell.typeNameLabel.text = type.displayName
        cell.typeNameLabel.textColor = Theme.labelColor
        cell.typeNameLabel.font = Theme.labelFont
        cell.backgroundColor = Theme.viewBackgroundColor

        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let ingredientTableVC = storyboard.instantiateViewController(withIdentifier: "ingredientStock") as! IngredientListController
        ingredientTableVC.user = user
        ingredientTableVC.userStore = userStore
        ingredientTableVC.ingredientStore = ingredientStore
        ingredientTableVC.coreDataStack = coreDataStack
        ingredientTableVC.ingredientType = type
        ingredientTableVC.defaults = defaults
        
        self.show(ingredientTableVC, sender: nil)
    }
    
    func refresh(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
