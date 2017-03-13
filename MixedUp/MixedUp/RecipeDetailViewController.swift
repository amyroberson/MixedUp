//
//  RecipeDetailViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/16/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit
import CoreData

class RecipeDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate  {
    
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
    var ingredients: Set<Ingredient> = []
   
    var drink: Drink? = nil
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var drinkNameTextField: UITextField!
    @IBOutlet weak var recipeInstructionLabel: UILabel!
    @IBOutlet weak var recipeInstructions: UITextView!
    @IBOutlet weak var selectIngredientsLabel: UILabel!
    @IBOutlet weak var ingredientTypePicker: UIPickerView!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var selectToolsLabel: UILabel!
    @IBOutlet weak var toolsPicker: UIPickerView!
    @IBOutlet weak var toolsLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var saveToFavoritesButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    var toolsStack = UIStackView()
    var ingredientStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientTypePicker.delegate = self
        ingredientTypePicker.dataSource = self
        ingredientTypePicker.isHidden = true
        successLabel.isHidden = true
        toolsPicker.delegate = self
        toolsPicker.dataSource = self
        toolsPicker.isHidden = true
        drinkNameTextField.delegate = self
        recipeInstructions.delegate = self
        recipeInstructions.textColor = .lightGray
        recipeInstructions.layer.cornerRadius = 5
        mainStackView.insertArrangedSubview(toolsStack, at: 12)
        mainStackView.insertArrangedSubview(ingredientStackView, at: 8)
        scrollView.showsVerticalScrollIndicator = false
        saveToFavoritesButton.isUserInteractionEnabled = true
        saveToFavoritesButton.setTitle("Save to Favorites", for: .normal)
        do{
            ingredientTypes = try typeStore?.fetchMainQueueTypes(predicate: nil, sortDescriptors: nil) ?? []
            tools = try toolStore?.fetchMainQueueTools(predicate: nil, sortDescriptors: nil) ?? []
            refresh()
        } catch{
            print("could not get object from CoreData")
        }
        setUpLabels()
        setUpStackView()
        refreshStackView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RecipeDetailViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func addIngredientTapped(_ sender: Any) {
        if saveToFavoritesButton.isUserInteractionEnabled {
            ingredientTypePicker.isHidden = false
        }
    }
    @IBAction func addToolTapped(_ sender: Any) {
        if saveToFavoritesButton.isUserInteractionEnabled{
            toolsPicker.isHidden = false
        }
    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        drinkNameTextField.resignFirstResponder()
        recipeInstructions.resignFirstResponder()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let drinkIngredients: Set<Ingredient> = ingredients
        var isShown = false
        for ingredient in drinkIngredients {
            for button in ingredientStackView.arrangedSubviews{
                let button = button as! UIButton
                if (button.title(for: .normal)!).contains((ingredient.displayName)!){
                    isShown = true
                }
            }
            if !isShown{
                let ingredientButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                ingredientButton.setTitle("\(ingredient.displayName ?? "")  X", for: .normal)
                ingredientButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
                ingredientButton.addTarget(self, action: #selector(removeIngredient(_:)), for: .touchUpInside)
                ingredientStackView.addArrangedSubview(ingredientButton)
            }
            isShown = false
        }
    }
    
    @IBAction func createDrinkTapped(_ sender: UIButton) {
        guard ingredients.count > 0 , drinkNameTextField.text != nil, drinkNameTextField.text != "" else {
            successLabel.isHidden = false
            successLabel.text = "Could not save drink, try adding more information"
            return
        }
        self.drink = NSEntityDescription.insertNewObject(forEntityName: Drink.entityName, into: (self.coreDataStack?.mainQueueContext)!) as? Drink
        drink?.isAlcoholic = true
        drink?.isIBAOfficial = false
        drink?.displayName = ""
        drink?.name = ""
        drink?.glass = glass
        drink?.color = color
        
        if let user = user,
            let _ = drinkStore,
            let name = drinkNameTextField.text,
            let instructions = recipeInstructions.text,
            let drink = drink
        {
            drink.stringDescription = instructions
            drink.ingredients = ingredients as NSSet?
            drink.displayName = name
            drink.isIBAOfficial = false
            drink.isAlcoholic = Util.getIsAlcoholic(ingredients: Array(ingredients))
            let result = (drinkStore?.createCoreDataDrink(newDrink: drink, inContext: (coreDataStack?.mainQueueContext)!))!
            switch result{
            case .success(let drink):
                self.drink = drink
            default:
                print("error creating drink")
            }
            user.addToFavoriteDrinks(drink)
            do {
                try coreDataStack?.saveChanges()
                sender.isUserInteractionEnabled = false
                sender.setTitle("Saved!", for: .normal)
                recipeInstructions.isUserInteractionEnabled = false
                drinkNameTextField.isUserInteractionEnabled = false
                ingredientStackView.isUserInteractionEnabled = false
                toolsStack.isUserInteractionEnabled = false
            }catch{
                print("couldn't save")
            }
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
        var drinkIngredients: Set<Ingredient> = ingredients
        for ingredient in drinkIngredients{
            let title = sender.title(for: .normal)
            if (title?.contains(ingredient.displayName!))!{
                drinkIngredients.remove(ingredient)
                ingredients.remove(ingredient)
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
        if ingredients.count > 0 {
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
            return ingredientTypes.count + 1
        } else {
            return tools.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == ingredientTypePicker{
            if row == 0 {
                return "All Ingredients"
            } else {
                return ingredientTypes[row - 1].displayName
            }
        } else {
            return tools[row].displayName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == ingredientTypePicker{
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let addVC = storyBoard.instantiateViewController(withIdentifier: "AddtoRecipe") as! AddToRecipeViewController
            addVC.defaults = defaults
            addVC.ingredientStore = ingredientStore
            if row != 0 {
                let type = ingredientTypes[row - 1]
                addVC.type = type
            }
            ingredientTypePicker.isHidden = true
            self.show(addVC, sender: nil)
        } else {
            drinkTools.insert(tools[row])
            var isShown = false
            for button in toolsStack.arrangedSubviews{
                let button = button as! UIButton
                if (button.title(for: .normal)!).contains((tools[row].displayName)!){
                    isShown = true
                }
            }
            if !isShown {
                let theToolButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                theToolButton.setTitle("\(tools[row].displayName ?? "")  X", for: .normal)
                theToolButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
                theToolButton.addTarget(self, action: #selector(removeTool(_:)), for: .touchUpInside)
                toolsStack.addArrangedSubview(theToolButton)
            }
            toolsPicker.isHidden = true
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter drink instructions"
            textView.textColor = UIColor.lightGray
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
        selectToolsLabel.textColor = Theme.labelColor
        selectToolsLabel.font = Theme.labelFont
        successLabel.textColor = Theme.labelColor
        successLabel.font = Theme.labelFont
    }
    
    func refresh(){
        DispatchQueue.main.async {
            self.ingredientTypePicker.reloadAllComponents()
            self.toolsPicker.reloadAllComponents()
        }
    }
}
