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
            let section = StructuredSection(
                identifier: country.title,
                rows: country.cities.map({ CityTableViewCellModel(city: $0) })
            )
            section.headerTitle = country.title
            return section
        }
        tableController.set(structure: structure, animation: TableAnimationRule(insert: .left, delete: .right, reload: .fade))
    }
    

}
