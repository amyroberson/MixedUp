//
//  GlassPickerViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/15/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class GlassPickerViewController: UIViewController, UICollectionViewDelegate {

    var defaults: UserDefaults? = nil
    var coreDataStack: CoreDataStack? = nil
    var userStore: UserService? = nil
    var ingredientStore: IngredientService? = nil
    var toolStore: ToolService? = nil
    var glassStore: GlassService? = nil
    var colorStore: ColorService? = nil
    var user: User? = nil
    var typeStore: TypeService? = nil
    var drinkStore: DrinkService? = nil
    var glasses: [Glass] = []
    @IBOutlet weak var selectLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        glassStore?.getAllGlasses(completion: {result in
            switch result{
            case .success(let theGlasses):
                self.glasses = theGlasses
                self.refresh()
                
            default:
                print("could not get glasses")
            }
        })
        
        self.navigationItem.title = "Create Drink"
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        view.backgroundColor = Theme.viewBackgroundColor
        selectLabel.font = Theme.boldLabelFont
        selectLabel.textColor = Theme.labelColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        if defaults?.string(forKey: Theme.themeKey) == Theme.lightKey{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let glass = glasses[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let colorVC = storyBoard.instantiateViewController(withIdentifier: "colorPicker") as! ColorPickerViewController
        colorVC.coreDataStack = coreDataStack
        colorVC.user = user
        colorVC.defaults = defaults
        colorVC.userStore = userStore
        colorVC.ingredientStore = ingredientStore
        colorVC.toolStore = toolStore
        colorVC.glassStore = glassStore
        colorVC.colorStore = colorStore
        colorVC.drinkStore = drinkStore
        colorVC.typeStore = typeStore
        colorVC.glass = glass
        self.show(colorVC, sender: nil)
    }
    
}

extension GlassPickerViewController: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return glasses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IBACell", for: indexPath) as! IBACell
      
        let glass = glasses[indexPath.row].displayName
        
        cell.drawGlass.color = UIColor(colorLiteralRed: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        cell.drawGlass.glass = glass ?? ""
        cell.drinkNameLabel.textColor = Theme.labelColor
        cell.drinkNameLabel.font = Theme.cellLabelFont
        cell.drinkNameLabel.text = glass
        
        return cell
    }
    
    
    
    func refresh(){
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
}
