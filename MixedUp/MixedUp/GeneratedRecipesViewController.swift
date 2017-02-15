//
//  GeneratedRecipesViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/9/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class GeneratedRecipesViewController: UIViewController, UICollectionViewDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    
    var defaults: UserDefaults? = nil
    var coreDataStack: CoreDataStack? = nil
    var userStore: UserService? = nil
    var drinkStore: DrinkService? = nil
    var user: User? = nil
    var drinks: [Drink] = []
    
    @IBOutlet weak var needMoreIngredientsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.title = "You Can Make These!"
        refresh()
        setUpLabel()
        needMoreIngredientsLabel.isHidden = true
        view.backgroundColor = Theme.viewBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drinkStore?.getGeneratedDrinks(user: self.user!, completion: {result in
            switch result{
            case .success(let genDrinks):
                self.drinks = genDrinks
                self.refresh()
                
            default:
                print("could not get drinks")
            }
        })
        if defaults?.string(forKey: "theme") == "Light"{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let drink = drinks[indexPath.row]
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(withIdentifier: "DrinkDetail") as! DrinkDetailViewController
        detailVC.coreDataStack = coreDataStack
        detailVC.user = user
        detailVC.drink = drink
        detailVC.userStore = userStore
        detailVC.drinkStore = drinkStore
        detailVC.defaults = defaults
        self.show(detailVC, sender: nil)
    }


}

extension GeneratedRecipesViewController: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drinks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IBACell", for: indexPath) as! IBACell
        
        
        let drink = drinks[indexPath.row]
        if let color = drink.color{
            let red = Float(color.red)/255
            let green =  Float(color.green)/255
            let blue =  Float(color.blue)/255
            let alpha =  Float(color.red)/255
            cell.drawGlass.color = UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: alpha)
        }
        
        cell.drawGlass.glass = drink.glass?.displayName ?? ""
        cell.drawGlass.descriptionString = drink.description
        cell.drinkNameLabel.textColor = Theme.labelColor
        cell.drinkNameLabel.font = Theme.cellLabelFont
        cell.drinkNameLabel.text = drink.displayName
        
        return cell
    }
    
    
    
    func refresh(){
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.drinks.count == 0 {
               self.needMoreIngredientsLabel.isHidden = false
            } else {
                self.needMoreIngredientsLabel.isHidden = true
            }
        }
    }
    func setUpLabel(){
        needMoreIngredientsLabel.textColor = Theme.labelColor
        needMoreIngredientsLabel.font = Theme.labelFont
    }
    
}
