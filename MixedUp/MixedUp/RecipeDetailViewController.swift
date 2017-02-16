//
//  RecipeDetailViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/16/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit
import CoreData

class RecipeDetailViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    var defaults: UserDefaults? = nil
    var coreDataStack: CoreDataStack? = nil
    var userStore: UserService? = nil
    var ingredientStore: IngredientService? = nil
    var toolStore: ToolService? = nil
    var glassStore: GlassService? = nil
    var colorStore: ColorService? = nil
    var drinkStore: DrinkService? = nil
    var user: User? = nil
    var typeStore: TypeService? = nil
    var glass: Glass? = nil
    var color: Color? = nil
    var ingredientTypes: [IngredientType] = []
    var type: IngredientType? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults?.string(forKey: Theme.themeKey) == Theme.lightKey{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
        self.view.backgroundColor = Theme.viewBackgroundColor
    }
    
    @IBAction func createDrinkTapped(_ sender: UIButton) {
        if let user = user, let color = color, let glass = glass, let _ = drinkStore{
            
            var newDrink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName, into: (self.coreDataStack?.mainQueueContext)!) as! Drink
            newDrink.glass = glass
            newDrink.color = color
            let result = (drinkStore?.createCoreDataDrink(newDrink: newDrink, inContext: (coreDataStack?.mainQueueContext)!))!
            switch result{
            case .success(let drink):
                newDrink = drink
                
            default:
                print("error creating drink")
            }
            user.favoriteDrinks?.adding(newDrink)
        }
        //turn off button till user changes display name? or just send user to favorites
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //switch over pickers
        return ingredientTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //switch over pickers
        return ingredientTypes[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //switch over pickers
        type = ingredientTypes[row]
        //send user to view to add ingredients
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
    
    func refresh(){
        DispatchQueue.main.async {
            //      self.ingredientTypePicker.reloadAllComponents()
        }
    }
}
