//
//  TableStructuredViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

public struct TableAnimationRule: Equatable {
    let insert, delete, reload: UITableView.RowAnimation
}

extension TableAnimationRule {
    
    public static let fade = TableAnimationRule(insert: .fade, delete: .fade, reload: .fade)

    public static let right = TableAnimationRule(insert: .right, delete: .right, reload: .right)

    public static let left = TableAnimationRule(insert: .left, delete: .left, reload: .left)

    public static let top = TableAnimationRule(insert: .top, delete: .top, reload: .top)

    public static let bottom = TableAnimationRule(insert: .bottom, delete: .bottom, reload: .bottom)

    public static let none = TableAnimationRule(insert: .none, delete: .none, reload: .none)

    public static let middle = TableAnimationRule(insert: .middle, delete: .middle, reload: .middle)

    public static let automatic = TableAnimationRule(insert: .automatic, delete: .automatic, reload: .automatic)
    
}

open class TableStructuredController: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    
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
        previousStructure = structure.map { oldSection -> StructuredSectionOld in
            return StructuredSectionOld(identifier: oldSection.identifier, rows: oldSection.rows.map({ cellOld -> StructuredCellOld in
                let cellOldIdentifable = cellOld as? StructuredCellIdentifable
                var contentHasher: Hasher?
                if let cellOldContentIdentifable = cellOld as? StructuredCellContentIdentifable {
                    contentHasher = Hasher()
                    cellOldContentIdentifable.contentHash(into: &contentHasher!)
                }
                return StructuredCellOld(
                    identifyHasher: cellOldIdentifable?.identifyHasher(for: .tableView),
                    contentHasher: contentHasher
                )
            }))
        }
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
            
//            CATransaction.begin()
            
            tableView.beginUpdates()
            
//            CATransaction.setCompletionBlock { [weak self] in
//                if !diff.rowsToReload.isEmpty {
//                    self?.tableView.reloadRows(at: diff.rowsToReload, with: animation.reload)
//                }
//            }
                    
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
            
//            CATransaction.commit()
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
    
    // MARK: - UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView)  {
        
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)  {
        
    }
    
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
    
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        
    }
    
}

