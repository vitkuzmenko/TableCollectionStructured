//
//  TableStructuredViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

open class TableStructuredController: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    
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
        let objectIdentifyHasher = object.identifyHasher(for: .tableView)
        return structure.indexPath(of: objectIdentifyHasher, structuredView: .tableView)?.indexPath
    }
        
    open func cellModel(at indexPath: IndexPath) -> Any {
        return structure[indexPath.section].rows[indexPath.row]
    }
    
    // MARK: - Registration
    
    open func register(_ tableView: UITableView, with cellModels: [StructuredCell.Type]) {
        self.tableView = tableView
        tableView.dataSource = self
        tableView.delegate = self
        
        let identifiers = cellModels.map({ $0.reuseIdentifier(for: .tableView) })
        tableView.registerNibs(with: identifiers)
    }
    
    // MARK: - Sctructure Updating
    
    open func set(structure newStructure: [StructuredSection], animation: TableAnimationRule = .fade) {
        previousStructure = structure.old(for: .tableView)
        structure = newStructure
        guard !previousStructure.isEmpty else {
            return tableView.reloadData()
        }
        switch animation {
        case .none:
            tableView.reloadData()
        default:
            performReload(with: animation)
        }
    }
    
    func performReload(with animation: TableAnimationRule) {
        do {
            let diff = try StructuredDifference(from: previousStructure, to: structure, structuredView: .tableView)
            
            tableView.beginUpdates()
                                
            for movement in diff.sectionsToMove {
                tableView.moveSection(movement.from, toSection: movement.to)
            }
            
            if !diff.sectionsToDelete.isEmpty {
                tableView.deleteSections(diff.sectionsToDelete, with: animation.delete)
            }
            
            if !diff.sectionsToInsert.isEmpty {
                tableView.insertSections(diff.sectionsToInsert, with: animation.insert)
            }
            
            for movement in diff.rowsToMove {
                tableView.moveRow(at: movement.from, to: movement.to)
            }
            
            if !diff.rowsToDelete.isEmpty {
                tableView.deleteRows(at: diff.rowsToDelete, with: animation.delete)
            }
            
            if !diff.rowsToInsert.isEmpty {
                tableView.insertRows(at: diff.rowsToInsert, with: animation.insert)
            }
            
            DispatchQueue.main.async { [weak self] in
                if !diff.rowsToReload.isEmpty {
                    self?.tableView.reloadRows(at: diff.rowsToReload, with: animation.reload)
                }
            }
            
            tableView.endUpdates()
            
        } catch let error {
            NSLog("TableStructuredController: Can not reload animated. %@", error.localizedDescription)
            tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return structure.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structure[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = cellModel(at: indexPath) as? StructuredCell else { fatalError("Model should be StructuredCell") }
        let cell = tableView.dequeueReusableCell(withModel: model, for: indexPath)
        return cell
    }
    
    // MARK: - Titles
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return structure[section].headerTitle
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return structure[section].footerTitle
    }
    
    // MARK: - Displaying
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellWillDisplay {
            object.willDisplay?(cell)
        }
    }
    
    // MARK: - Sizing
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let object = self.cellModel(at: indexPath) as? StructuredCellDynamicHeight {
            return object.height(for: tableView)
        } else {
            return tableView.rowHeight
        }
    }
    
    // MARK: - Selection
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellSelectable, let cell = tableView.cellForRow(at: indexPath) {
            if let deselect = object.didSelect?(cell), deselect {
                self.tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
        
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellDeselectable {
            let cell = tableView.cellForRow(at: indexPath)
            object.didDeselect?(cell)
        }
    }
    
    // MARK: - Editing
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let object = self.cellModel(at: indexPath) as? StructuredCellEditable {
            return object.canEdit?() ?? false
        }
        return false
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if let object = self.cellModel(at: indexPath) as? StructuredCellEditable {
            return object.editingStyle?() ?? .none
        }
        return .none
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellEditable {
            object.commitEditing?(editingStyle)
        }
    }
    
    // MARK: - Moving
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let object = self.cellModel(at: indexPath) as? StructuredCellMovable {
            return object.canMove?() ?? false
        }
        return false
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let object = self.cellModel(at: sourceIndexPath) as? StructuredCellMovable {
            object.didMove?(sourceIndexPath, destinationIndexPath)
        }
    }
    
    // MARK: - Focus
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if let object = self.cellModel(at: indexPath) as? StructuredCellFocusable {
            return object.canFocus?() ?? false
        }
        return false
    }
    
    // MARK: - Section Header
    
//    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
//
//    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return nil
//    }
    
    // MARK: - Section Footer
    
//    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
//
//    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
    
}

