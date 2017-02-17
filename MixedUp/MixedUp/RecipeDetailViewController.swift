//
//  RecipeDetailViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/16/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit
import CoreData

class RecipeDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
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
    var tools: [Tool] = []
    var drinkTools: Set<Tool> = []
    var type: IngredientType? = nil
    var ingredients: [Ingredient] = []
    var drinkIngredients: Set<Ingredient> = []
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var drinkNameTextField: UITextField!
    @IBOutlet weak var recipeInstructionLabel: UILabel!
    @IBOutlet weak var recipeInstructionTextField: UITextField!
    @IBOutlet weak var selectIngredientsLabel: UILabel!
    @IBOutlet weak var ingredientTypePicker: UIPickerView!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var selectToolsLabel: UILabel!
    @IBOutlet weak var toolsPicker: UIPickerView!
    @IBOutlet weak var toolsLabel: UILabel!
    @IBOutlet weak var saveToFavoritesButton: UIButton!
    
    var toolsStack = UIStackView()
    var ingredientStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientTypePicker.delegate = self
        ingredientTypePicker.dataSource = self
        ingredientTypePicker.isHidden = true
        toolsPicker.delegate = self
        toolsPicker.dataSource = self
        toolsPicker.isHidden = true
        mainStackView.insertArrangedSubview(toolsStack, at: 12)
        mainStackView.insertArrangedSubview(ingredientStackView, at: 10)
        toolStore?.getAllTools(completion: {result in
            switch result{
            case .success(let tools):
                self.tools = tools
                self.refresh()
            default:
                print("could not get tools")
            }
        })
        typeStore?.getAllTypes(completion: {result in
            switch result{
            case .success(let types):
                self.ingredientTypes = types
                self.refresh()
            default:
                print("could not get ingredient types")
            }
        })
        setUpLabels()
        setUpStackView()
        refreshStackView()
    }
    
    @IBAction func addIngredientTapped(_ sender: Any) {
        ingredientTypePicker.isHidden = false
    }
    @IBAction func addToolTapped(_ sender: Any) {
        toolsPicker.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults?.string(forKey: Theme.themeKey) == Theme.lightKey{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
        refresh()
        self.view.backgroundColor = Theme.viewBackgroundColor
        for ingredient in drinkIngredients {
            let ingredientButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            ingredientButton.setTitle("\(ingredient.displayName ?? "")  X", for: .normal)
            ingredientButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            ingredientButton.addTarget(self, action: #selector(removeIngredient(_:)), for: .touchUpInside)
            ingredientStackView.addArrangedSubview(ingredientButton)
        }
    }
    
    @IBAction func createDrinkTapped(_ sender: UIButton) {
        guard ingredients.count > 0 else {return}
        
        if let user = user, let color = color, let glass = glass, let _ = drinkStore, let name = drinkNameTextField.text, let instructions = recipeInstructionTextField.text{
            
            var newDrink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName, into: (self.coreDataStack?.mainQueueContext)!) as! Drink
            newDrink.glass = glass
            newDrink.color = color
            newDrink.stringDescription = instructions
            newDrink.displayName = name
            newDrink.isIBAOfficial = false
            newDrink.isAlcoholic = Util.getIsAlcoholic(ingredients: ingredients)
            let result = (drinkStore?.createCoreDataDrink(newDrink: newDrink, inContext: (coreDataStack?.mainQueueContext)!))!
            switch result{
            case .success(let drink):
                newDrink = drink
                
            default:
                print("error creating drink")
            }
            user.favoriteDrinks?.adding(newDrink)
        } else {
            //display a label to get more info
        }
    }
    
    func setUpStackView(){
        toolsStack.alignment = .center
        toolsStack.axis = .vertical
        toolsStack.setContentHuggingPriority(0.7, for: .vertical)
        toolsStack.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        toolsStack.distribution = .fill
        ingredientStackView.alignment = .center
        ingredientStackView.axis = .vertical
        ingredientsLabel.setContentHuggingPriority(0.7, for: .vertical)
        ingredientStackView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        ingredientStackView.distribution = .fill
    }
    
    func removeIngredient(_ sender: UIButton){
        for ingredient in drinkIngredients{
            if ingredient.displayName == sender.title(for: .normal){
                drinkIngredients.remove(ingredient)
                sender.removeFromSuperview()
            }
        }
    }
    
    func removeTool(_ sender: UIButton){
        for tool in drinkTools{
            if tool.displayName == sender.title(for: .normal) {
                drinkTools.remove(tool)
                sender.removeFromSuperview()
            }
        }
    }
    
    func refreshStackView(){
        let theToolLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        if drinkTools.count > 0 {
            theToolLabel.center = CGPoint(x: 160, y: 285)
            theToolLabel.textAlignment = .center
            theToolLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            theToolLabel.text = "Add a tool"
            theToolLabel.textColor = Theme.labelColor
            theToolLabel.font = Theme.labelFont
            toolsStack.addArrangedSubview(theToolLabel)
            
        } else{
            toolsStack.removeArrangedSubview(theToolLabel)
        }
        let theIngredientLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        if drinkIngredients.count > 0 {
            theIngredientLabel.center = CGPoint(x: 160, y: 285)
            theIngredientLabel.textAlignment = .center
            theIngredientLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            theIngredientLabel.text = "Add some ingredients"
            theIngredientLabel.textColor = Theme.labelColor
            theIngredientLabel.font = Theme.labelFont
            ingredientStackView.addArrangedSubview(theIngredientLabel)
        } else{
            ingredientStackView.removeArrangedSubview(theIngredientLabel)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == ingredientTypePicker{
            return ingredientTypes.count
        } else {
            return tools.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == ingredientTypePicker{
            return ingredientTypes[row].displayName
        } else {
            return tools[row].displayName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == ingredientTypePicker{
            //send to ingredientPicker
        } else {
            drinkTools.insert(tools[row])
            let theToolButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            theToolButton.setTitle("\(tools[row].displayName ?? "")  X", for: .normal)
            theToolButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            theToolButton.addTarget(self, action: #selector(removeTool(_:)), for: .touchUpInside)
            toolsStack.addArrangedSubview(theToolButton)
            toolsPicker.isHidden = true

        }
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
    
    func setUpLabels(){
        drinkNameLabel.textColor = Theme.labelColor
        drinkNameLabel.font = Theme.labelFont
        recipeInstructionLabel.textColor = Theme.labelColor
        recipeInstructionLabel.font = Theme.labelFont
        selectIngredientsLabel.font = Theme.labelFont
        selectIngredientsLabel.textColor = Theme.labelColor
        ingredientsLabel.font = Theme.labelFont
        ingredientsLabel.textColor = Theme.labelColor
        toolsLabel.font = Theme.labelFont
        toolsLabel.textColor = Theme.labelColor
    }
    
    func refresh(){
        DispatchQueue.main.async {
            self.ingredientTypePicker.reloadAllComponents()
            self.toolsPicker.reloadAllComponents()
        }
    }
}
