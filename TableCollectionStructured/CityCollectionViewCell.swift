//
//  CityCollectionViewCell.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 01/11/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

class CityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    
    weak var city: City! {
        didSet {
            textLabel?.text = city.title
        }
    }
    
}
