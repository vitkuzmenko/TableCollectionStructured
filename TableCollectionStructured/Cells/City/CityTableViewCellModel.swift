//
//  CityTableViewCell.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 27.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

class CityTableViewCellModel: StructuredCellConfigurable {
    
    var identifyHashable: AnyHashable?
    
    var identifyHasher: Hasher?
    
    let text: String
    
    init(city: City) {
        identifyHashable = city.name
        text = city.name
    }
    
    static func reuseIdentifier(for parentView: StructuredView) -> String {
        return "CityTableViewCell"
    }
    
    func configure(cell: CityTableViewCell) {
        cell.textLabel?.text = text
    }
    
}
