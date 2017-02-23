//
//  IBAViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit
import CoreData

class IBAViewController: UIViewController, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var coreDataStack: CoreDataStack? = nil
    var drinkStore: DrinkService? = nil
    var userStore: UserService? = nil
    var user: User? = nil
    var defaults: UserDefaults? = nil
    var drinks: [Drink] = []
    var allDrinks: [Drink] = []
    var filteredDrinks: Set<Drink> = []
    var inSearchMode = false
    @IBOutlet weak var drinkSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drinkStore?.getIBADrinks(completion: {result in
            switch result{
            case .success(let ibas):
                self.drinks = ibas
                self.allDrinks = ibas
                self.refresh()
            default:
                print("could not get drinks from server")
                self.drinks = (self.drinkStore?.getAllDrinksFromCoreData())!
                self.allDrinks = self.drinks
                self.refresh()
            }
        })
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.navigationItem.title = "IBA Drink Recipes"
        drinkSearchBar.delegate = self
        drinkSearchBar.returnKeyType = UIReturnKeyType.done
        drinkSearchBar.placeholder = "Search by Name and Ingredients"
        let button: UIButton = UIButton(type: .custom)
        button.setTitle("Random", for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 0.4784, blue: 1, alpha: 1.0), for:.normal)
        button.addTarget(self, action: #selector(FavoritesViewController.randomDrinkPressed), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 90, height: 51)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults?.string(forKey: Theme.themeKey) == Theme.lightKey{
            Theme.styleLight()
        } else {
            Theme.styleDark()
        }
        self.view.backgroundColor = Theme.viewBackgroundColor
    }
    
    func randomDrinkPressed(){
        if drinks.count > 0 {
        let random = Int(arc4random_uniform(UInt32(drinks.count)))
        let drink = drinks[random]
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if drinkSearchBar.text == nil || drinkSearchBar.text == ""{
            inSearchMode = false
            drinks = allDrinks
            collectionView.reloadData()
            view.endEditing(true)
        } else {
            inSearchMode = true
            let text = drinkSearchBar.text?.lowercased()
            drinks = Util.searchDrinks(allDrinks: allDrinks, searchText: text!)
            collectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        drinks = allDrinks
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        drinks = allDrinks
    }
}

extension IBAViewController: UICollectionViewDataSource{
    
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
            let alpha =  Float(color.alpha)
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
        }
    }
}
