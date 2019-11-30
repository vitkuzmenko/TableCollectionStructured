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
        makeStructure()
    }
    
    func configureTableView() {
        tableController.register(tableView, with: [
            CityTableViewCellModel.self
        ])
    }
    
    @IBAction func makeStructure() {
        let structure = CitiesDataSource().countries().map { country -> StructuredSection in
            var section = StructuredSection(
                identifier: country.title,
                rows: country.cities.map({ CityTableViewCellModel(city: $0) })
            )
            section.headerTitle = country.title
            return section
        }
        tableController.set(structure: structure, animation: TableAnimationRule(insert: .left, delete: .right, reload: .fade))
    }
    

}
