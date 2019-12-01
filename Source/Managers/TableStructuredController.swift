//
//  TableStructuredViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

public enum StructuredView {
    case tableView(UITableView)
    case collectionView(UICollectionView)
}

final class TableStructuredController: NSObject {
    
    private var structuredView: StructuredView!
    
    public weak var scrollViewDelegate: UIScrollViewDelegate?
    
    // MARK: - TableViewParameters
    
    internal weak var tableViewDelegate: UITableViewDelegate?
    
    internal weak var tableViewDataSourcePrefetching: UITableViewDataSourcePrefetching?
        
    // MARK: - CollectionView
    
    // MARK: - Structure
    
    public var structure: [StructuredSection] = []
    
    private var previousStructure: [StructuredSectionOld] = [] {
        didSet {
            structure.forEach { section in
                section.rows.forEach { object in
                    if let invalidatableCell = object as? StructuredCellInvalidatable {
                        invalidatableCell.invalidated()
                    }
                }
            }
        }
    }
    
    public func indexPath(for object: StructuredCellIdentifable) -> IndexPath? {
        let objectIdentifyHasher = object.identifyHasher(for: structuredView)
        return structure.indexPath(of: objectIdentifyHasher, structuredView: structuredView)?.indexPath
    }
        
    public func cellModel(at indexPath: IndexPath) -> Any? {
        if structure.count - 1 >= indexPath.section {
            let section = structure[indexPath.section]
            if section.rows.count - 1 >= indexPath.row {
                return section.rows[indexPath.row]
            }
        }
        return nil
    }
    
    // MARK: - Registration
    
    public func register(_ tableView: UITableView, cellModelTypes: [StructuredCell.Type] = [], headerFooterModelTypes: [StructuredSectionHeaderFooter.Type] = [], tableViewDelegate: UITableViewDelegate? = nil, tableViewDataSourcePrefetching: UITableViewDataSourcePrefetching? = nil) {
        
        if self.structuredView != nil {
            fatalError("TableStructuredController: Registration may be once")
        }
        
        self.structuredView = .tableView(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        cellModelTypes.forEach { type in
            let identifier = type.reuseIdentifier(for: structuredView)
            let nib = UINib(nibName: identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: identifier)
        }
        
        headerFooterModelTypes.forEach { type in
            let identifier = type.reuseIdentifier(for: structuredView)
            let nib = UINib(nibName: identifier, bundle: nil)
            tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
        }
    }
    
    // MARK: - Sctructure Updating
    
    public func set(structure newStructure: [StructuredSection], animation: TableAnimationRule = .fade) {
        guard let structuredView = structuredView else { fatalError("StructuredView is not configured") }
        previousStructure = structure.old(for: structuredView)
        structure = newStructure
        switch structuredView {
        case .tableView(let tableView):
            guard !previousStructure.isEmpty else {
                return tableView.reloadData()
            }
            switch animation {
            case .none:
                tableView.reloadData()
            default:
                do {
                    let diff = try StructuredDifference(from: previousStructure, to: structure, structuredView: .tableView(tableView))
                    performTableViewReload(tableView, diff: diff, with: animation)
                } catch let error {
                    NSLog("TableStructuredController: Can not reload animated. %@", error.localizedDescription)
                    tableView.reloadData()
                }
            }
        case .collectionView(let collectionView):
            break
        }
    }
        
}

