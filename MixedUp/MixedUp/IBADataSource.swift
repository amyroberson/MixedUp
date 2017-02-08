//
//  IBADataSource.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class IBADataSource: NSObject, UICollectionViewDataSource {
    
    var coreDataStack = CoreDataStack(modelName: "MixedUpDataModel")
    
    func setup(){
        let drink1 = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName,
                                                         into: coreDataStack.privateQueueContext) as! Drink
        drink1.displayName = "Mixer"
        drink1.name = "mixer"
        drink1.id = "twv4"
        let rum = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                      into: coreDataStack.privateQueueContext) as! Ingredient
        rum.name = "rum"
        let shaker = NSEntityDescription.insertNewObject(forEntityName: Tool.entityName,
                                                         into: coreDataStack.privateQueueContext) as! Tool
        shaker.name = "shaker"
        drink1.tools = [shaker]
        drinks = [drink1]
    }
    
    var drinks: [Drink] = []
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        setup()
        return drinks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IBACell", for: indexPath) as! IBACell
        
        
        let drink = drinks[indexPath.row]
        
        cell.drinkNameLabel.text = drink.displayName
        
        return cell
    }
}
