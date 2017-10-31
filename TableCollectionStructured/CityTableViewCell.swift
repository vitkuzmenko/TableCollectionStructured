//
//  CityTableViewCell.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 31/10/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    weak var city: City! {
        didSet {
            textLabel?.text = city.title
        }
    }

}
