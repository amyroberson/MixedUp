//
//  addInventoryViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit
import CoreData

class addInventoryViewController: UIViewController, UITextFieldDelegate {

    var coreDataStack: CoreDataStack? = nil
    var ingredientStore: IngredientService? = nil
    var userStore: UserService? = nil
    var user: User? = nil
    var ingredientType: IngredientType? = nil

    @IBOutlet weak var typeDisplayLabel: UILabel!
    @IBOutlet weak var displayNameTextField: UITextField!
  
    @IBAction func addIngredientPressed(_ sender: UIButton) {
        let ingredient = NSEntityDescription.insertNewObject(forEntityName: Ingredient.entityName,
                                                             into: (coreDataStack?.mainQueueContext)!) as! Ingredient
        ingredient.type = ingredientType!
        ingredient.displayName = displayNameTextField.text!
        let result = ingredientStore?.createCoreDataIngredient(newIngredient: ingredient, inContext: (coreDataStack?.mainQueueContext)!)
            switch result!{
            case .success(let tempIngredient):
                if let user = user, let inventory = user.inventory{
                    user.inventory = (inventory.adding(tempIngredient) as NSSet)
                }
            default:
                print("ingredient did not get created")
            }
    
        let arrayCount: Int = Int((navigationController?.viewControllers.count)!)
        if arrayCount >= 2 {
            let uiVC: UIViewController = (navigationController?.viewControllers[arrayCount - 2])!
            let _ = self.navigationController?.popToViewController(uiVC, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let ingredientType = ingredientType{
            typeDisplayLabel.text = ingredientType.displayName
        }
        displayNameTextField.delegate = self
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty == true {
            return false
        } else {
            textField.resignFirstResponder()
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty == true {
            return false
        } else {
            textField.resignFirstResponder()
            return true
        }
    }
    

}
