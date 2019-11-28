//
//  CitiesDataSource.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 27.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

class CitiesDataSource {
    
    func countries() -> [Country] {
        return [
            Country(title: "USA", cities: usa()),
            Country(title: "Russia", cities: russia())
        ]
    }
    
    func usa() -> [City] {
        return [
            City(name: "New York"),
            City(name: "Las Vegas"),
            City(name: "San Francisco"),
            City(name: "Los Angeles")
            ].shuffled().dropLast(Int.random(in: 0...3))
    }
    
    func russia() -> [City] {
        return [
            City(name: "Moscow"),
            City(name: "Rostov-on-Don"),
            City(name: "st. Pitersberg"),
            City(name: "Vladivostok")
            ].shuffled().dropLast(Int.random(in: 0...3))
    }
    
}
