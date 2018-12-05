//
//  ViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit



class CollectionViewController: UIViewController, CollectionStructuredViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var collectionController: CollectionController = { return .init(vc: self) }()
    
    var cities: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        collectionController.configureCollectionView()
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
    
    func randRange (lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    @objc func nextStep() {
        
        collectionController.buildStructure(rule: .animated)
        
        print(step)
        
        step += 1
        
        if step == 10 {
            step = 0
        }
        
        startTimer()
    }
    
}

class CollectionController: CollectionStructuredController<CollectionViewController> {
    
    override func buildStructure(rule: CollectionViewReloadRule) {
        
        beginBuilding()
//
        switch vc.step {
        case 0:

            var section = newSection()
            section.headerTitle = "World"

            section.append(contentsOf: vc.cities)

            append(section: &section)

        case 1: // Split to regions

            var section = newSection()

            section.headerTitle = "Europe"
            section.append(City.paris)
            section.append(City.rome)
            section.append(City.moscow)
            section.append(City.prague)
            section.append(City.milan)

            append(section: &section)

            section.headerTitle = "Asia"
            section.append(City.tokyo)
            section.append(City.bangkok)
            section.append(City.hongKong)
            section.append(City.singapore)

            append(section: &section)

            section.headerTitle = "America"
            section.append(City.newYork)
            section.append(City.sanFrancisco)
            section.append(City.miami)
            section.append(City.lasVegas)

            append(section: &section)

        case 2: // Reorder inside one section

            var section = newSection()
            section.headerTitle = "Europe"
            section.append(City.paris)
            section.append(City.milan)
            section.append(City.prague)
            section.append(City.moscow)
            section.append(City.rome)

            append(section: &section)

            section.headerTitle = "Asia"
            section.append(City.hongKong)
            section.append(City.tokyo)
            section.append(City.singapore)
            section.append(City.bangkok)

            append(section: &section)
            section.headerTitle = "America"
            section.append(City.newYork)
            section.append(City.lasVegas)
            section.append(City.miami)
            section.append(City.sanFrancisco)

            append(section: &section)

        case 3: // Delete Section

            var section = newSection()
            section.headerTitle = "Europe"
            section.append(City.paris)
            section.append(City.milan)
            section.append(City.prague)
            section.append(City.moscow)
            section.append(City.rome)

            append(section: &section)
            section.headerTitle = "America"
            section.append(City.newYork)
            section.append(City.lasVegas)
            section.append(City.miami)
            section.append(City.sanFrancisco)

            append(section: &section)

        case 4: // Move section

            var section = newSection()

            section.headerTitle = "America"
            section.append(City.newYork)
            section.append(City.lasVegas)
            section.append(City.miami)
            section.append(City.sanFrancisco)

            append(section: &section)

            section.headerTitle = "Europe"
            section.append(City.paris)
            section.append(City.milan)
            section.append(City.prague)
            section.append(City.moscow)
            section.append(City.rome)

            append(section: &section)

        case 5: // Move section

            var section = newSection()

            section.headerTitle = "Europe"
            section.append(City.paris)
            section.append(City.milan)
            section.append(City.prague)
            section.append(City.moscow)
            section.append(City.rome)

            append(section: &section)

            section.headerTitle = "Asia"
            section.append(City.hongKong)
            section.append(City.tokyo)
            section.append(City.singapore)
            section.append(City.bangkok)

            append(section: &section)

            section.headerTitle = "America"
            section.append(City.newYork)
            section.append(City.lasVegas)
            section.append(City.miami)
            section.append(City.sanFrancisco)

            append(section: &section)

        case 6: // Grouping

            var section = newSection()

            section.headerTitle = "Near Sea"
            section.append(City.hongKong)
            section.append(City.tokyo)
            section.append(City.singapore)
            section.append(City.bangkok)
            section.append(City.miami)
            section.append(City.sanFrancisco)

            append(section: &section)

            section.headerTitle = "Not Near Sea"
            section.append(City.paris)
            section.append(City.milan)
            section.append(City.prague)
            section.append(City.moscow)
            section.append(City.rome)
            section.append(City.lasVegas)

            append(section: &section)

        case 7: // Grouping

            var section = newSection()

            section.headerTitle = "Everyday Summer Cities"
            section.append(City.hongKong)
            section.append(City.singapore)
            section.append(City.bangkok)
            section.append(City.miami)
            section.append(City.sanFrancisco)

            append(section: &section)

            section.headerTitle = "Cold Cities"
            section.append(City.moscow)
            section.append(City.prague)
            section.append(City.rome)

            append(section: &section)

        case 8: // Moving

            var section = newSection()

            section.headerTitle = "Everyday Summer Cities"
            section.append(City.hongKong)
            section.append(City.singapore)
            section.append(City.moscow)
            section.append(City.prague)
            section.append(City.rome)

            append(section: &section)

            section.headerTitle = "Cold Cities"
            section.append(City.sanFrancisco)
            section.append(City.bangkok)
            section.append(City.miami)

            append(section: &section)

        case 9: // Moving and deleting cells

            var section = newSection()

            section.headerTitle = "Everyday Summer Cities"
            section.append(City.hongKong)
            section.append(City.sanFrancisco)

            append(section: &section)

            section.headerTitle = "Cold Cities"
            section.append(City.moscow)
            section.append(City.rome)

            append(section: &section)


        default:
            break
        }
//
        super.buildStructure(rule: rule)
    }
    
    
   
    
}

