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
                                                             into: (coreDataStack?.privateQueueContext)!) as! Ingredient
        ingredient.type = ingredientType!
        ingredient.displayName = displayNameTextField.text!
        ingredientStore?.createIngredient(ingredient: ingredient, completion: {result in
            switch result{
            case .success(let ingredients):
                if ingredients.count > 0{
                    let ingredient = ingredients[0]
                    self.user?.inventory?.adding(ingredient)
                }
            default:
                print("ingredient did not get created")
            }
        })
        
        userStore?.updateUser(user: user!, caseString: "inventory", completion: {result in
            switch result{
            case .success(let users):
                if users.count > 0{
                    self.user = users[0]
                }
            default:
                print("user did not get updated")
            }})
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
