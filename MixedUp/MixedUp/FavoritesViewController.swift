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
    var favoriteDrinks:  [Drink] = []{
        didSet{
            createRandomButton()
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Favorite Drinks"
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        view.backgroundColor = Theme.viewBackgroundColor
        if let user = user {
            favoriteDrinks = Array(user.favoriteDrinks ?? []) as! [Drink]
        }
        
        collectionView.showsVerticalScrollIndicator = false
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
    
    func createRandomButton(){
        if favoriteDrinks.count > 1 {
            let button: UIButton = UIButton(type: .custom)
            button.setTitle("Random", for: .normal)
            button.setTitleColor(UIColor(red: 0, green: 0.4784, blue: 1, alpha: 1.0), for:.normal)
            button.addTarget(self, action: #selector(FavoritesViewController.randomDrinkPressed), for: UIControlEvents.touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 90, height: 51)
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
        }
    }
    
    
    func randomDrinkPressed(){
        if favoriteDrinks.count > 0 {
            let random = Int(arc4random_uniform(UInt32(favoriteDrinks.count)))
            let drink = favoriteDrinks[random]
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
            if let user = self.user {
                self.favoriteDrinks = Array(user.favoriteDrinks ?? []) as! [Drink]
            }
            self.collectionView.reloadData()
        }
    }
}
