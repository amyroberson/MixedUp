//
//  AddToRecipeViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/17/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class AddToRecipeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var defaults: UserDefaults? = nil
    var ingredientStore: IngredientService? = nil
    var type: IngredientType? = nil
    var ingredients: [Ingredient] = []{
        didSet {
            self.ingredient = ingredients[0]
        }
    }
    var ingredient: Ingredient? = nil
    var drink: Drink? = nil
    
    @IBOutlet weak var selectLabel: UILabel!
    
    @IBOutlet weak var ingredientPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientPicker.dataSource = self
        ingredientPicker.delegate = self
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addIngredient(_:)))
        if type == nil{
            self.ingredientStore?.getAllIngredients(completion:  {result in
                switch result{
                case .success(let theIngredients):
                    self.ingredients = theIngredients
                    self.refresh()
                    
                default:
                    print("could not get ingredients")
                }
            })
        }else {
            ingredientStore?.getIngredientsOfType(type: type!, completion: {result in
                switch result{
                case .success(let theIngredients):
                    self.ingredients = theIngredients
                    self.refresh()
                default:
                    print("could not get ingredients")
                }
            })
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults?.string(forKey: Theme.themeKey) == Theme.lightKey{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
    }
    
    func addIngredient(_ sender: UIButton){
        if let drink = drink, let ingredient = ingredient {
            drink.ingredients = drink.ingredients?.adding(ingredient) as NSSet?
        }
        let arrayCount: Int = Int((navigationController?.viewControllers.count)!)
        if arrayCount >= 2 {
            let uiVC: UIViewController = (navigationController?.viewControllers[arrayCount - 2])!
            let _ = self.navigationController?.popToViewController(uiVC, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ingredients.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ingredients[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        ingredient = ingredients[row]
    }
    
    func refresh(){
        DispatchQueue.main.async {
            self.ingredientPicker.reloadAllComponents()
        }
    }
    
}
