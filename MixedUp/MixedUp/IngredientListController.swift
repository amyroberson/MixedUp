//
//  IngredientListController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class IngredientListController: UITableViewController {

    var coreDataStack: CoreDataStack? = nil
    var ingredientStore: IngredientService? = nil
    var userStore: UserService? = nil
    var user: User? = nil
    var ingredientType: IngredientType? = nil
    var ingredients: [Ingredient] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inventory = user?.inventory
        if let inventory = inventory {
            for ingredient in inventory{
                if (ingredient as! Ingredient).type == ingredientType{
                    ingredients.append((ingredient as! Ingredient))
                }
            }
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
        self.title = ingredientType?.displayName
        tableView.delegate = self
        tableView.dataSource = self
    }

    func addTapped(_ sender: UIBarButtonItem){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let addInventoryVC = storyBoard.instantiateViewController(withIdentifier: "AddInventory") as! addInventoryViewController
        addInventoryVC.coreDataStack = coreDataStack
        addInventoryVC.user = user
        addInventoryVC.ingredientType = ingredientType
        addInventoryVC.ingredientStore = ingredientStore
        
        self.show(addInventoryVC, sender: nil)
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ingredient = ingredients[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredient", for: indexPath) as! IngredientCell
        cell.ingredientNameLabel.text = ingredient.displayName
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
 

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

}