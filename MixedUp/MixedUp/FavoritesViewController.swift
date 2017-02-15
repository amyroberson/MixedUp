//
//  FavoritesViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/9/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit


class FavoritesViewController: UIViewController, UICollectionViewDelegate {
    
    var defaults: UserDefaults? = nil
    var coreDataStack: CoreDataStack? = nil
    var userStore: UserService? = nil
    var drinkStore: DrinkService? = nil
    var user: User? = nil
    var favoriteDrinks:  [Drink] = []
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favorite Drinks"
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        view.backgroundColor = Theme.viewBackgroundColor
        if let user = user {
            favoriteDrinks = Array(user.favoriteDrinks ?? []) as! [Drink]
        }
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
        let drink = favoriteDrinks[indexPath.row]
        
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

extension FavoritesViewController: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteDrinks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IBACell", for: indexPath) as! IBACell
        
        
        let drink = favoriteDrinks[indexPath.row]
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
            if let user = self.user {
                self.favoriteDrinks = Array(user.favoriteDrinks ?? []) as! [Drink]
            }
            self.collectionView.reloadData()
        }
    }
    
    
}
