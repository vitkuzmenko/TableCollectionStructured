//
//  CityTableViewCell.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 27.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

class CityTableViewCellModel {
            
    let title: String
    
    let population: String
    
    init(city: City) {
        title = city.name
        population = String(city.population)
    }
    
}

extension CityTableViewCellModel: StructuredTableViewCell {
    
    class func reuseIdentifierForTableView() -> String {
        return "CityTableViewCell"
    }
    
    func configure(tableViewCell cell: CityTableViewCell) {
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = population
    }
    
}

extension CityTableViewCellModel: StructuredCellIdentifable {
    
    func identifyHash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
}

extension CityTableViewCellModel: StructuredCellContentIdentifable {

    func contentHash(into hasher: inout Hasher) {
        hasher.combine(population)
    }

}
