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

    
    func setTypes(){
        let type1 = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                                    into: (coreDataStack?.privateQueueContext)!) as! IngredientType
        type1.displayName = "Mixer"
        
        let type2 = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                        into: (coreDataStack?.privateQueueContext)!) as! IngredientType
        type2.displayName = "Liquor"
        let type3 = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                        into: (coreDataStack?.privateQueueContext)!) as! IngredientType
        type3.displayName = "Liquers"
        let type4 = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                        into: (coreDataStack?.privateQueueContext)!) as! IngredientType
        type4.displayName = "Garnishes"
        types = [type1, type2, type3, type4]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTypes()
        self.title = "Inventory"
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.reloadData()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Type", for: indexPath) as! IngredientTypeCell

        let type = types[indexPath.row]
        
        cell.typeNameLabel.text = type.displayName

        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //pass along ingredient type for adding ingedients later
    }

}
