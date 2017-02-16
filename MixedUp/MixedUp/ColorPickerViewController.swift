//
//  ColorPickerViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/16/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController, UICollectionViewDelegate {

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
    var colors: [Color] = []
    @IBOutlet weak var selectLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        colorStore?.getAllColors(completion: { result in
            switch result{
            case .success(let theColors):
                self.colors = theColors
                self.refresh()
                
            default:
                print("could not get colors")

            }
        })
        selectLabel.font = Theme.boldLabelFont
        selectLabel.textColor = Theme.labelColor
        self.title = "Create Drink"
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        view.backgroundColor = Theme.viewBackgroundColor
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
        let color = colors[indexPath.row]
        //send to drink recipe detail VC
    }
}

extension ColorPickerViewController: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IBACell", for: indexPath) as! IBACell
        
        let color = colors[indexPath.row]
        let colorName = colors[indexPath.row].displayName
        let glassName = glass?.displayName
       
        let red = Float(color.red)/255
        let green =  Float(color.green)/255
        let blue =  Float(color.blue)/255
        let alpha =  Float(color.red)/255
        cell.drawGlass.color = UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: alpha)
        cell.drawGlass.glass = glassName ?? ""
        cell.drinkNameLabel.textColor = Theme.labelColor
        cell.drinkNameLabel.font = Theme.cellLabelFont
        cell.drinkNameLabel.text = colorName ?? ""
        
        return cell
    }
    
    
    
    func refresh(){
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
}
