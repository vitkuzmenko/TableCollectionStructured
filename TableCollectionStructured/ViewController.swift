//
//  ViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 27.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var tableController = TableStructuredController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        makeStrucuture()
    }
    
    func configureTableView() {
        tableController.register(tableView, with: [
            CityTableViewCellModel.self
        ])
    }
    
    @IBAction func makeStrucuture() {
        let structure = CitiesDataSource().countries().map { country -> StructuredSection in
            let rows = country.cities.map({ CityTableViewCellModel(city: $0) })
            let section = StructuredSection(identifier: country.title)
            section.rows = rows
            section.headerTitle = country.title
            
//            section.append(contentsOf: country.cities.map({ CityTableViewCellModel(city: $0) }))
//            country.cities.forEach { city in
//                let cellModel = CityTableViewCellModel(city: city)
//                section.append(cellModel)
//            }
            return section
        }        
        tableController.set(structure: structure, animation: .fade)
    }
    

}
