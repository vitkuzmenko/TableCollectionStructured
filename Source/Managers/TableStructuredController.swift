//
//  TableStructuredViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

open class TableStructuredController: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet open weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            configureTableView()
        }
    }
    
    open var structure: [StructuredSection] = []
    
    open var shouldReloadData: Bool { return true }
    
    private var previousStructure: [StructuredSection] = [] {
        didSet {
            structure.forEach { section in
                section.rows.forEach { object in
                    if let invalidatableCell = object.value as? StructuredCellInvalidatable {
                        invalidatableCell.invalidated()
                    }
                }
            }
        }
    }
    
    open func indexPath<T: StructuredCell>(for object: T) -> IndexPath? {
        let obj = StructuredObject(value: object)
        return structure.indexPath(of: obj)
    }
    
    open func isSafe(indexPath: IndexPath) -> Bool {
        if structure.isEmpty {
            return false
        } else if structure.count - 1 >= indexPath.section {
            if structure[indexPath.section].isEmpty {
                return false
            } else if structure[indexPath.section].count - 1 >= indexPath.row {
                return true
            }
        }
        return false
    }
    
    open func object(at indexPath: IndexPath) -> Any {
        return structure[indexPath.section][indexPath.row]
    }
    
    open func set(structure: [StructuredSection], animation: UITableView.RowAnimation = .fade) {
        beginBuilding()
        self.structure = structure
        buildStructure(with: animation)
    }
    
    open func beginBuilding() {
        previousStructure = structure
        structure = []
    }
    
    open func newSection(identifier: String? = nil) -> StructuredSection {
        return StructuredSection(identifier: identifier)
    }
    
    open func append(section: StructuredSection) {
        section.isClosed = true
        if structure.contains(section) {
            fatalError("TableCollectionStructured: Table structure is contains section with \"\(section.identifier!)\" identifier")
        }
        if section.identifier == nil {
            section.identifier = String(format: "#Section%d", structure.count)
        }
        
        for _section in structure {
            for row in section.rows {
                if _section.rows.contains(where: { (obj) -> Bool in
                    return obj == row
                }) {
                    
                }
            }
        }
        
        structure.append(section)
    }
    
    open func append(section: inout StructuredSection, new identifier: String? = nil) {
        append(section: section)
        section = StructuredSection(identifier: identifier)
    }
    
    open func configureTableView() {
        tableView.tableFooterView = UIView()
    }
    
    open func buildStructure(with animation: UITableView.RowAnimation? = nil) {
        if let animation = animation {
            self.performReload(with: animation)
        }
    }
    
    open func reloadData() {
        tableView.reloadData()
    }
    
    var queue: Int = 0
    
    open func performReload(with animation: UITableView.RowAnimation = .fade) {
        
        if animation == .none {
            if shouldReloadData {
                reloadData()
            }
            return
        }
        
        let diff = StructuredDifference(from: previousStructure, to: structure)
        
        if !diff.reloadConstraint.isEmpty || tableView.window == nil {
            return reloadData()
        }
        
        CATransaction.begin()
        
        tableView.beginUpdates()
        
        if shouldReloadData {
            CATransaction.setCompletionBlock { [weak self] in
                self?.tableView?.reloadData()
            }
        }
        
        for movement in diff.sectionsToMove {
            tableView.moveSection(movement.from, toSection: movement.to)
        }
        
        if !diff.sectionsToDelete.isEmpty {
            tableView.deleteSections(diff.sectionsToDelete, with: animation)
        }
        
        if !diff.sectionsToInsert.isEmpty {
            tableView.insertSections(diff.sectionsToInsert, with: animation)
        }
        
        for movement in diff.rowsToMove {
            tableView.moveRow(at: movement.from, to: movement.to)
        }
        
        if !diff.rowsToDelete.isEmpty {
            tableView.deleteRows(at: diff.rowsToDelete, with: animation)
        }
        
        if !diff.rowsToInsert.isEmpty {
            tableView.insertRows(at: diff.rowsToInsert, with: animation)
        }
        
        tableView.endUpdates()
        
        CATransaction.commit()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return structure.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structure[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = object(at: indexPath) as? StructuredCell else { fatalError("Model should be StructuredCellModelProtocol") }
        let cell = tableView.dequeueReusableCell(withModel: model, for: indexPath)
        return cell
    }
    
    @available(*, deprecated, message: "deprecated")
    open func tableView(_ tableView: UITableView, reuseIdentifierFor object: Any) -> String? {
        fatalError("Depreacted")
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return structure[section].headerTitle
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return structure[section].footerTitle
    }
    
    @available(*, deprecated, message: "deprecated")
    open func tableView(_ tableView: UITableView, configure cell: UITableViewCell, for object: Any, at indexPath: IndexPath) {
        
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let object = self.object(at: indexPath) as? StructuredCellWillDisplay {
            object.willDisplay?()
        }
    }
    
//    @available(*, deprecated, message: "")
//    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, for object: Any) {
//
//    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let object = self.object(at: indexPath) as? StructuredCellDynamicHeight {
            return object.height(for: tableView)
        } else {
            return tableView.rowHeight
        }
    }
    
    @available(*, deprecated, message: "deprecated")
    open func rowHeight(forIdentifier identifier: String) -> CGFloat {
        return tableView.rowHeight
    }
    
    @available(*, deprecated, message: "deprecated")
    open func rowHeight(forObject object: Any) -> CGFloat {
        if let object = object as? String {
            return rowHeight(forIdentifier: object)
        }
        return tableView.rowHeight
    }
    
    open var automaticallyDeselect: Bool {
        return true
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let object = self.object(at: indexPath) as? StructuredCellSelectable, let cell = tableView.cellForRow(at: indexPath) {
            if let deselect = object.didSelect?(cell), deselect {
                self.tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    @available(*, deprecated, message: "deprecated")
    open func tableView(_ tableView: UITableView, didSelect cell: UITableViewCell, with identifier: String, object: Any, at indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let object = self.object(at: indexPath) as? StructuredCellDeselectable {
            object.didDeselect?()
        }
    }
    
    @available(*, deprecated, message: "deprecated")
    open func tableView(_ tableView: UITableView, didDeselect cell: UITableViewCell, with identifier: String, object: Any, at indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let object = self.object(at: indexPath)
        return self.tableView(tableView, canEditRowWith: object, at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, canEditRowWith object: Any, at indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let object = self.object(at: indexPath)
        self.tableView(tableView, commit: editingStyle, for: object, forRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, for object: Any, forRowAt indexPath: IndexPath) {
        
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
    
    open func reloadRows<T: StructuredCell>(objects: [T], with animation: UITableView.RowAnimation = .fade) {
        
        var indexPaths: [IndexPath] = []
        for object in objects {
            if let indexPath = self.indexPath(for: object) {
                indexPaths.append(indexPath)
            }
        }
        
        tableView.reloadRows(at: indexPaths, with: animation)
    }
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        guard let reuseIdentifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier else { return true }
        return self.tableView(tableView, canFocus: object(at: indexPath), with: reuseIdentifier, at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, canFocus object: Any, with identifier: String, at indexPath: IndexPath) -> Bool {
        return true
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
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

