//
//  CityTableViewCell.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 27.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

class CityTableViewCellModel: StructuredCellAssociated, StructuredCellIdentifable {
    
    var identifyHashable: AnyHashable
        
    let text: String
    
    let population: String
    
    init(city: City) {
        identifyHashable = city.name
        text = city.name
        population = String(city.population)
    }
    
    static func reuseIdentifier(for parentView: StructuredView) -> String {
        return "CityTableViewCell"
    }
    
    func configure(cell: CityTableViewCell) {
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = population
    }
    
}

extension CityTableViewCellModel: StructuredCellContentIdentifable {

    func contentHash(into hasher: inout Hasher) {
        hasher.combine(population)
    }

}
