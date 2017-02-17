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
    var all: IngredientType? = nil
    var drink: Drink? = nil
    
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
        mainStackView.insertArrangedSubview(ingredientStackView, at: 8)
        do{
            ingredientTypes = try typeStore?.fetchMainQueueTypes(predicate: nil, sortDescriptors: nil) ?? []
            tools = try toolStore?.fetchMainQueueTools(predicate: nil, sortDescriptors: nil) ?? []
            refresh()
        } catch{
            print("could not get objectd from CoreData")
        }
        all = NSEntityDescription.insertNewObject(forEntityName: IngredientType.entityName,
                                                  into: self.coreDataStack!.mainQueueContext) as? IngredientType
        all?.displayName = "All Ingredients"
        ingredientTypes.append(all!)
        self.drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName, into: (self.coreDataStack?.mainQueueContext)!) as? Drink
        drink?.isAlcoholic = true
        drink?.isIBAOfficial = false
        drink?.displayName = ""
        drink?.name = ""
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
        
        setUpIngredientStack()
    }
    
    func setUpIngredientStack(){
        let drinkIngredients: Set<Ingredient> = Set(drink?.ingredients?.allObjects as! [Ingredient])
        for ingredient in drinkIngredients {
            let ingredientButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            ingredientButton.setTitle("\(ingredient.displayName ?? "")  X", for: .normal)
            ingredientButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
            ingredientButton.addTarget(self, action: #selector(removeIngredient(_:)), for: .touchUpInside)
            ingredientStackView.addArrangedSubview(ingredientButton)}

    }
    
    
    @IBAction func createDrinkTapped(_ sender: UIButton) {
        guard drink?.ingredients?.count ?? 0 > 0 else {return}
        
        if let user = user, let color = color, let glass = glass, let _ = drinkStore, let name = drinkNameTextField.text, let instructions = recipeInstructionTextField.text, let drink = drink{
            drink.glass = glass
            drink.color = color
            drink.stringDescription = instructions
            drink.displayName = name
            drink.isIBAOfficial = false
            drink.isAlcoholic = Util.getIsAlcoholic(ingredients: ingredients)
            let result = (drinkStore?.createCoreDataDrink(newDrink: drink, inContext: (coreDataStack?.mainQueueContext)!))!
            switch result{
            case .success(let drink):
                self.drink = drink
            default:
                print("error creating drink")
            }
            user.favoriteDrinks?.adding(drink)
            
            do {
                try coreDataStack?.saveChanges()
            }catch{
                print("couldn't save")
            }
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
        var drinkIngredients: Set<Ingredient> = Set(drink?.ingredients?.allObjects as! [Ingredient])
        for ingredient in drinkIngredients{
            let title = sender.title(for: .normal)
            if (title?.contains(ingredient.displayName!))!{
                drinkIngredients.remove(ingredient)
                sender.removeFromSuperview()
            }
        }
    }
    
    func removeTool(_ sender: UIButton){
        for tool in drinkTools{
            let title = sender.title(for: .normal)
            if (title?.contains(tool.displayName!))! {
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
        if (drink?.ingredients?.count) ?? 0 > 0 {
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
            let type = ingredientTypes[row]
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let addVC = storyBoard.instantiateViewController(withIdentifier: "AddtoRecipe") as! AddToRecipeViewController
            addVC.defaults = defaults
            addVC.ingredientStore = ingredientStore
            addVC.drink = drink
            addVC.type = type
            ingredientTypePicker.isHidden = true
            self.show(addVC, sender: nil)
            
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
