//
//  addInventoryViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit
import CoreData

class addInventoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var coreDataStack: CoreDataStack? = nil
    var ingredientStore: IngredientService? = nil
    var userStore: UserService? = nil
    var user: User? = nil
    var ingredientType: IngredientType? = nil
    var ingredients: [Ingredient] = []{
        didSet {
        self.ingredient = ingredients[0]
        }
    }
    var ingredient: Ingredient? = nil

    @IBOutlet weak var typeDisplayLabel: UILabel!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var ingredientPicker: UIPickerView!
  
    @IBAction func addIngredientPressed(_ sender: UIButton) {
       if let user = user, let inventory = user.inventory, let ingredient = self.ingredient{
            ingredient.type = ingredientType
            user.inventory = (inventory.adding(ingredient) as NSSet)
        do{
            try coreDataStack?.saveChanges()
            }catch{
                print("could not save")
            }
       } else {
            print("ingredient did not get saved to user")
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
        ingredientPicker.delegate = self
        ingredientPicker.dataSource = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ingredientStore?.getIngredientsOfType(type: ingredientType!, completion: {result in
            switch result{
            case .success(let theIngredients):
                self.ingredients = theIngredients
                self.refresh()
                
            default:
                print("could not get drinks")
            }
        })
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ingredients.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ingredients[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ingredient = ingredients[row]
        
    }
    
    func refresh(){
        DispatchQueue.main.async {
            self.ingredientPicker.reloadAllComponents()
        }
    }

}
