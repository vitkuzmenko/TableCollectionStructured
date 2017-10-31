//
//  TableStructuredViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

public protocol TableStructuredViewController: class {
    var tableView: UITableView! { get set }
}

open class TableStructuredController<ViewController: TableStructuredViewController>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet open weak var tableView: UITableView!
    
    open weak var vc: ViewController!
    
    open var tableStructure: [StructuredSection] = []
    
    private var previousTableStructure: [StructuredSection] = []
    
    public convenience init(vc: ViewController) {
        self.init()
        tableView = vc.tableView
        tableView.dataSource = self
        tableView.delegate = self
        self.vc = vc
        
        configureTableView()
    }
    
    open func indexPath<T: Equatable>(for object: T) -> IndexPath? {
        let obj = StructuredObject(value: object)
        for (sectionIndex, section) in tableStructure.enumerated() {
            if let rowIndex = section.rows.index(of: obj) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    open func object(_ object: Any, isEqualTo _object: Any) -> Bool? {
        return nil
    }
    
    open func isSafe(indexPath: IndexPath) -> Bool {
        if tableStructure.isEmpty {
            return false
        } else if tableStructure.count - 1 >= indexPath.section {
            if tableStructure[indexPath.section].isEmpty {
                return false
            } else if tableStructure[indexPath.section].count - 1 >= indexPath.row {
                return true
            }
        }
        return false
    }
    
    open func object(at indexPath: IndexPath) -> Any {
        return tableStructure[indexPath.section][indexPath.row]
    }
    
    open func beginBuilding() {
        canAppendNew = true
        previousTableStructure = tableStructure
        tableStructure = []
    }
    
    open func newSection(identifier: String) -> StructuredSection {
        return StructuredSection(identifier: identifier)
    }
    
    private var canAppendNew = true
    
    open func append(section: inout StructuredSection, newIdentifier: String? = nil) {
        if !canAppendNew { fatalError("Can not append new section, because when appended last section, is not set identifier for new section") }
        tableStructure.append(section)
        if let newIdentifier = newIdentifier {
            section = StructuredSection(identifier: newIdentifier)
            canAppendNew = true
        } else {
            canAppendNew = false
        }
    }
    
    open func configureTableView() {
        tableView.tableFooterView = UIView()
    }
    
    open func buildTableStructure(with animation: UITableViewRowAnimation) {
        
        if animation == .none { return tableView!.reloadData() }
        
        var sectionsToMove: [(from: Int, to: Int)] = []
        
        var sectionsToDelete = IndexSet()
        
        var sectionsToInsert = IndexSet()
        
        var rowsToMove: [(from: IndexPath, to: IndexPath)] = []
        
        var rowsToDelete: [IndexPath] = []
        
        var rowsToInsert: [IndexPath] = []
        
        for (previousSectionIndex, section) in previousTableStructure.enumerated() {
            if let newSectionIndex = tableStructure.index(of: section) {
                if previousSectionIndex != newSectionIndex {
                    sectionsToMove.append((from: previousSectionIndex, to: newSectionIndex))
                }
            } else {
                sectionsToDelete.insert(previousSectionIndex)
            }
        }
        
        for (newSectionIndex, section) in tableStructure.enumerated() {
            if !previousTableStructure.contains(section) {
                sectionsToInsert.insert(newSectionIndex)
            }
        }
        
        for (previousSectionIndex, section) in previousTableStructure.enumerated() {
            for (previousRowIndex, row) in section.rows.enumerated() {
                let previousIndexPath = IndexPath(row: previousRowIndex, section: previousSectionIndex)
                if let newRowIndexPath = tableStructure.indexPath(of: row) {
                    if previousIndexPath != newRowIndexPath {
                        if tableStructure.contains(section) {
                            let newSection = tableStructure[newRowIndexPath.section]
                            if previousTableStructure.contains(newSection) {
                                rowsToMove.append((from: previousIndexPath, to: newRowIndexPath))
                            } else {
                                rowsToDelete.append(previousIndexPath)
                            }
                        } else {
                            rowsToInsert.append(newRowIndexPath)
                        }
                    }
                } else {
                    rowsToDelete.append(previousIndexPath)
                }
            }
        }
        
        for (newSectionIndex, section) in tableStructure.enumerated() {
            
            for (newRowIndex, row) in section.rows.enumerated() {
                if !previousTableStructure.contains(structured: row) {
                    rowsToInsert.append(IndexPath(row: newRowIndex, section: newSectionIndex))
                }
            }
            
        }
        
        tableView.beginUpdates()
        
        for movement in sectionsToMove {
            tableView.moveSection(movement.from, toSection: movement.to)
        }
        
        tableView.deleteSections(sectionsToDelete, with: animation)
        
        tableView.insertSections(sectionsToInsert, with: animation)
        
        for movement in rowsToMove {
            tableView.moveRow(at: movement.from, to: movement.to)
        }
        
        tableView.deleteRows(at: rowsToDelete, with: animation)
        
        tableView.insertRows(at: rowsToInsert, with: animation)
        
        tableView.endUpdates()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.object(at: indexPath)
        guard let identifier = self.tableView(tableView, reuseIdentifierFor: object) else {
            fatalError("Reuse identifier for this object is not configured in tableView(_:reuseIdentifierFor:)")
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        self.tableView(tableView, configure: cell, for: object, at: indexPath)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, reuseIdentifierFor object: Any) -> String? {
        var identifier: String?
        if let object = object as? String {
            identifier = object
        }
        return identifier
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableStructure[section].headerTitle
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableStructure[section].footerTitle
    }
    
    open func tableView(_ tableView: UITableView, configure cell: UITableViewCell, for object: Any, at indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let object = self.object(at: indexPath)
        self.tableView(tableView, willDisplay: cell, for: object)
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, for object: Any) {
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = self.object(at: indexPath)
        return rowHeight(forObject: object)
    }
    
    open func rowHeight(forIdentifier identifier: String) -> CGFloat {
        return tableView.rowHeight
    }
    
    open func rowHeight(forObject object: Any) -> CGFloat {
        if let object = object as? String {
            return rowHeight(forIdentifier: object)
        }
        return tableView.rowHeight
    }
    
    open var automaticallyDeselect: Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if automaticallyDeselect {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let identifier = cell.reuseIdentifier else { return }
        let object = self.object(at: indexPath)
        
        self.tableView(tableView, didSelect: cell, with: identifier, object: object, at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelect cell: UITableViewCell, with identifier: String, object: Any, at indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if automaticallyDeselect {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let identifier = cell.reuseIdentifier else { return }
        let object = self.object(at: indexPath)
        
        self.tableView(tableView, didDeselect: cell, with: identifier, object: object, at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didDeselect cell: UITableViewCell, with identifier: String, object: Any, at indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let object = self.object(at: indexPath)
        return self.tableView(tableView, canEditRowWith: object, at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, canEditRowWith object: Any, at indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let object = self.object(at: indexPath)
        self.tableView(tableView, commit: editingStyle, for: object, forRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, for object: Any, forRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let object = self.object(at: indexPath)
        return self.tableView(tableView, canMove: object, at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, canMove object: Any, at indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let object = self.object(at: sourceIndexPath)
        self.tableView(tableView, move: object, from: sourceIndexPath, to: destinationIndexPath)
    }
    
    open func tableView(_ tableView: UITableView, move object: Any, from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    open func reloadRows<T: Equatable>(objects: [T]) {
        
        var indexPaths: [IndexPath] = []
        for object in objects {
            if let indexPath = self.indexPath(for: object) {
                indexPaths.append(indexPath)
            }
        }
        
        tableView.reloadRows(at: indexPaths, with: .fade)
    }
    
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
