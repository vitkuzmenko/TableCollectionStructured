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

extension City {
    
    // Europe
    
    static let paris = City(title: "Paris")
    
    static let rome = City(title: "Rome")
    
    static let moscow = City(title: "Moscow")
    
    static let prague = City(title: "Prague")
    
    static let milan = City(title: "Milan")
    
    // Asia
    
    static let tokyo = City(title: "Tokyo")
    
    static let bangkok = City(title: "Bangkok")
    
    static let hongKong = City(title: "Hong Kong")
    
    static let singapore = City(title: "Singapore")
    
    // America

    static let newYork = City(title: "New York")
    
    static let sanFrancisco = City(title: "San Francisco")
    
    static let miami = City(title: "Miami")
    
    static let lasVegas = City(title: "Las Vegas")
    
}

class TableViewController: UIViewController, TableStructuredViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var tableController: TableController = { return .init(vc: self) }()
    
    var cities: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        tableController.configureTableView()
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nextStep()
    }
    
    func loadData() {
        cities = [.paris, .rome, .moscow, .prague, .milan, .tokyo, .bangkok, .hongKong, .singapore, .newYork, .sanFrancisco, .miami, .lasVegas]
    }
    
    var step = 0
    
    func startTimer() {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(nextStep), userInfo: nil, repeats: false)
    }
    
    @objc func nextStep() {
        
        tableController.buildTableStructure(with: .fade)
        
        print(step)
        
        step += 1
        
        if step == 6 {
            step = 0
        }
        
        startTimer()
    }

}

class TableController: TableStructuredController<TableViewController> {
    
    override func buildTableStructure(with animation: UITableViewRowAnimation) {
        
        beginBuilding()
        
        switch vc.step {
        case 0:

            var section = newSection(identifier: "World")
            section.useIdentifierAsHeaderTitle()

            section.append(contentsOf: vc.cities)

            append(section: &section)

        case 1: // Split to regions

            var section = newSection(identifier: "Europe")
            section.useIdentifierAsHeaderTitle()
            section.append(City.paris)
            section.append(City.rome)
            section.append(City.moscow)
            section.append(City.prague)
            section.append(City.milan)

            append(section: &section, newIdentifier: "Asia")
            section.useIdentifierAsHeaderTitle()
            section.append(City.tokyo)
            section.append(City.bangkok)
            section.append(City.hongKong)
            section.append(City.singapore)

            append(section: &section, newIdentifier: "America")
            section.useIdentifierAsHeaderTitle()
            section.append(City.newYork)
            section.append(City.sanFrancisco)
            section.append(City.miami)
            section.append(City.lasVegas)

            append(section: &section)

        case 2: // Reorder inside one section

            var section = newSection(identifier: "Europe")
            section.useIdentifierAsHeaderTitle()
            section.append(City.paris)
            section.append(City.milan)
            section.append(City.prague)
            section.append(City.moscow)
            section.append(City.rome)

            append(section: &section, newIdentifier: "Asia")
            section.useIdentifierAsHeaderTitle()
            section.append(City.hongKong)
            section.append(City.tokyo)
            section.append(City.singapore)
            section.append(City.bangkok)

            append(section: &section, newIdentifier: "America")
            section.useIdentifierAsHeaderTitle()
            section.append(City.newYork)
            section.append(City.lasVegas)
            section.append(City.miami)
            section.append(City.sanFrancisco)

            append(section: &section)

        case 3: // Delete Section

            var section = newSection(identifier: "Europe")
            section.useIdentifierAsHeaderTitle()
            section.append(City.paris)
            section.append(City.milan)
            section.append(City.prague)
            section.append(City.moscow)
            section.append(City.rome)

            append(section: &section, newIdentifier: "America")
            section.useIdentifierAsHeaderTitle()
            section.append(City.newYork)
            section.append(City.lasVegas)
            section.append(City.miami)
            section.append(City.sanFrancisco)

            append(section: &section)
            
        case 4: // Reorder Section
            
            var section = newSection(identifier: "Europe")
            section.useIdentifierAsHeaderTitle()
            section.append(City.newYork)
            section.append(City.lasVegas)
            
            append(section: &section, newIdentifier: "America")
            section.useIdentifierAsHeaderTitle()
            
            section.append(City.paris)
            section.append(City.milan)
            
            append(section: &section)
            
        case 5: // Reorder Section
            
            var section = newSection(identifier: "America")
            section.useIdentifierAsHeaderTitle()
            section.append(City.newYork)
            section.append(City.paris)
            
            append(section: &section, newIdentifier: "Europe")
            section.useIdentifierAsHeaderTitle()
            
            section.append(City.lasVegas)
            section.append(City.milan)
            
            append(section: &section)
            
        default:
            break
        }
        
        super.buildTableStructure(with: animation)
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
