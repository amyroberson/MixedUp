//
//  IBASCollectionViewController.swift
//  MixedUp
//
//  Created by Amy Roberson on 2/8/17.
//  Copyright © 2017 Amy Roberson. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class IBASCollectionViewController: UICollectionViewController {

    var dataSource: IBADataSource? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "IBA")
        self.collectionView?.dataSource = dataSource
        self.collectionView?.delegate = self

    }



    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
    }


}
