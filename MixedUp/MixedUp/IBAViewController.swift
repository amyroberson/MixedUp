//
//  IBAViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

class IBAViewController: UIViewController, UICollectionViewDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: IBADataSource? = IBADataSource()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "IBA")
        self.collectionView?.dataSource = dataSource
        self.collectionView?.delegate = self
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
    }

}
