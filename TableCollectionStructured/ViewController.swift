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
    
    func makeStrucuture() {
        var structure: [StructuredSection] = []
        
        let dataSource = CitiesDataSource()
        
        let russiaSection = StructuredSection(identifier: "russia")
        russiaSection.headerTitle = "Russia"
        dataSource.russia().forEach { city in
            let cellModel = CityTableViewCellModel(city: city)
            russiaSection.append(cellModel)
        }
        
        structure.append(russiaSection)
        
        let usaSection = StructuredSection(identifier: "usa")
        usaSection.headerTitle = "USA"
        dataSource.usa().forEach { city in
            let cellModel = CityTableViewCellModel(city: city)
            usaSection.append(cellModel)
        }
        
        structure.append(usaSection)
        
        tableController.set(structure: structure, animation: .fade)
    }
    

}
