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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        refresh()
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
        
        cell.drinkNameLabel.textColor = Theme.labelColor
        cell.drinkNameLabel.font = Theme.cellLabelFont
        cell.drinkNameLabel.text = drink.displayName
        
        return cell
    }
    
    
    
    func refresh(){
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
}
