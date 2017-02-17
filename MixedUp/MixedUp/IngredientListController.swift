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
    var defaults: UserDefaults? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
        self.title = ingredientType?.displayName
        view.backgroundColor = Theme.viewBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults?.string(forKey: Theme.themeKey) == Theme.lightKey{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
        refreshView()
    }

    func addTapped(_ sender: UIBarButtonItem){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let addInventoryVC = storyBoard.instantiateViewController(withIdentifier: "AddInventory") as! addInventoryViewController
        addInventoryVC.coreDataStack = coreDataStack
        addInventoryVC.user = user
        addInventoryVC.ingredientType = ingredientType
        addInventoryVC.ingredientStore = ingredientStore
        addInventoryVC.defaults = defaults
        self.show(addInventoryVC, sender: nil)
        
    }
    

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
        cell.ingredientNameLabel.textColor = Theme.labelColor
        cell.ingredientNameLabel.font = Theme.labelFont
        cell.backgroundColor = Theme.viewBackgroundColor
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func refreshView(){
        let inventory = user?.inventory
        if let inventory = inventory {
            for ingredient in inventory{
                if (ingredient as! Ingredient).type?.displayName == ingredientType?.displayName{
                    if !ingredients.contains((ingredient as! Ingredient)){
                        ingredients.append((ingredient as! Ingredient))
                    }
                } else if ingredientType == nil{
                 ingredients = user?.inventory?.allObjects as! [Ingredient]
                }
            }
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
