//
//  ViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/6/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class BirthdayViewController: UIViewController {

    var defaults: UserDefaults? = nil
    
    @IBOutlet weak var mustBeLabel: UILabel!
    
    
    @IBAction func enterPressed(_ sender: UIButton) {
        let today = Date()
        let twentyOneYearsAgo = Calendar.current.date(byAdding: .year, value: -21, to: today)
        
        if birthdayPicker.date > twentyOneYearsAgo!{
            mustBeLabel.isHidden = false
        } else {
            defaults?.set(true, forKey: "Over21")
            let storyBoard = UIStoryboard(name: "Main", bundle: .main)
            let tabsVC = storyBoard.instantiateViewController(withIdentifier: "Tabs") as! TabsViewController
            self.show(tabsVC, sender: nil)
        }
        
        
    }
    
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mustBeLabel.isHidden = true
        
    }


}

