//
//  ViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

class City: Equatable {
    
    static func ==(lhs: City, rhs: City) -> Bool {
        return lhs.title == rhs.title
    }
    
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
}

class TableViewController: UIViewController, TableStructuredViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var tableController: TableController = { return .init(vc: self) }()
    
    var cities: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        tableController.buildTableStructure(reloadData: false)
    }

    func loadData() {
        let cities = ["New York", "Tokyo", "Moscow", "Paris", "Singapore", "London", "Hong Kong", "Male", "Dubai", "Milan"]
        self.cities = cities.map({ City(title: $0) })
    }

}

class TableController: TableStructuredController<TableViewController> {
    
    override func buildTableStructure(reloadData: Bool) {
    
        beginBuilding()
        
        var section = newSection()
        
        section.append(contentsOf: vc.cities)
        
        append(section: &section)
        
        super.buildTableStructure(reloadData: reloadData)
    }
    
    override func tableView(_ tableView: UITableView, reuseIdentifierFor object: Any) -> String? {
        if object is City {
            return "CityTableViewCell"
        } else {
            return super.tableView(tableView, reuseIdentifierFor: object)
        }
    }
    
    override func tableView(_ tableView: UITableView, configure cell: UITableViewCell, for object: Any, at indexPath: IndexPath) {
        if let cell = cell as? CityTableViewCell, let city = object as? City {
            cell.city = city
        }
    }
    
}
