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

open class TableStructuredController: NSObject {
    
    private var structuredView: StructuredView!
    
    public weak var scrollViewDelegate: UIScrollViewDelegate?
    
    open var structure: [StructuredSection] = []
    
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
    
    open func indexPath(for object: StructuredCellIdentifable) -> IndexPath? {
        let objectIdentifyHasher = object.identifyHasher(for: structuredView)
        return structure.indexPath(of: objectIdentifyHasher, structuredView: structuredView)?.indexPath
    }
        
    open func cellModel(at indexPath: IndexPath) -> Any {
        return structure[indexPath.section].rows[indexPath.row]
    }
    
    // MARK: - Registration
    
    open func register(_ strcturedView: StructuredView, cellModelTypes: [StructuredCell.Type] = [], headerFooterModelTypes: [StructuredSectionHeaderFooter.Type] = []) {
        if self.structuredView != nil {
            fatalError("TableStructuredController: Registration may be once")
        }
        self.structuredView = strcturedView
        switch strcturedView {
        case .tableView(let tableView):
            register(tableView, cellModelTypes: cellModelTypes, headerFooterModelTypes: headerFooterModelTypes)
        case .collectionView(let collectionView):
            break
        }
    }
    
    private func register(_ tableView: UITableView, cellModelTypes: [StructuredCell.Type] = [], headerFooterModelTypes: [StructuredSectionHeaderFooter.Type] = []) {
        
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
    
    open func set(structure newStructure: [StructuredSection], animation: TableAnimationRule = .fade) {
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

