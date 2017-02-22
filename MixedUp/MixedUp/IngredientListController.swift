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
        self.navigationItem.title = ingredientType?.displayName ?? "All Ingredients"
        view.backgroundColor = Theme.viewBackgroundColor
        tableView.delegate = self
        tableView.separatorColor = UIColor.darkGray
        tableView.dataSource = self
        self.tableView.allowsMultipleSelectionDuringEditing = false
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            let ingredeintToRemove = self.ingredients[indexPath.row]
            ingredeintToRemove.removeFromUser(self.user!)
            do {
                try self.coreDataStack?.saveChanges()
            } catch{
                print("could not save")
            }
            self.refreshView()
        })
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
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
    
    func refreshView(){
        let inventory = user?.inventory?.allObjects as! [Ingredient]
        ingredients = []
        for ingredient in inventory{
            if (ingredient).type?.displayName == ingredientType?.displayName{
                if !ingredients.contains(ingredient){
                    ingredients.append(ingredient)
                }
            } else if ingredientType == nil{
                ingredients = user?.inventory?.allObjects as! [Ingredient]
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
