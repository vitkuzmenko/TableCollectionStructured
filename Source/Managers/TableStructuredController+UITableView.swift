//
//  TableStructuredController+UITableView.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 30.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

extension TableStructuredController {
    
    func performTableViewReload(_ tableView: UITableView, diff: StructuredDifference, with animation: TableAnimationRule) {
            
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
            guard let `self` = self else { return }
            
            if !diff.rowsToReload.isEmpty {
                tableView.reloadRows(at: diff.rowsToReload, with: animation.reload)
            }
            
            if !diff.sectionHeadersToReload.isEmpty {
                diff.sectionHeadersToReload.forEach { index in
                    if let header = self.structure[index].header, let headerView = tableView.headerView(forSection: index) {
                        switch header {
                        case .text(let text):
                            headerView.textLabel?.text = text
                            headerView.textLabel?.sizeToFit()
                        case .view(let viewModel):
                            viewModel.configureAny(view: headerView, isUpdating: true)
                        }
                    }
                }
            }
            
            if !diff.sectionFootersToReload.isEmpty {
                diff.sectionFootersToReload.forEach { index in
                    if let footer = self.structure[index].footer, let footerView = tableView.footerView(forSection: index) {
                        switch footer {
                        case .text(let text):
                            footerView.textLabel?.text = text
                            footerView.textLabel?.sizeToFit()
                        case .view(let viewModel):
                            viewModel.configureAny(view: footerView, isUpdating: true)
                        }
                    }
                }
            }
        }
        
        tableView.endUpdates()
        
    }
        
}

extension TableStructuredController: UITableViewDataSource {
    
    // MARK: - Row
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structure[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = cellModel(at: indexPath) as? StructuredCell else { fatalError("Model should be StructuredCell") }
        let indetifier = type(of: model).reuseIdentifier(for: .tableView(tableView))
        let cell = tableView.dequeueReusableCell(withIdentifier: indetifier, for: indexPath)
        model.configureAny(cell: cell)
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return structure.count
    }
    
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let header = structure[section].header else { return nil }
        switch header {
        case .text(let text):
            return text
        default:
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let footer = structure[section].footer else { return nil }
        switch footer {
        case .text(let text):
            return text
        default:
            return nil
        }
    }
    
    // MARK: - Editing
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let object = self.cellModel(at: indexPath) as? StructuredCellEditable {
            return object.canEdit
        }
        return false
    }
    
    // MARK: - Moving/reordering
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let object = self.cellModel(at: indexPath) as? StructuredCellMovable {
            return object.canMove?() ?? false
        }
        return false
    }
    
    // MARK: - Index
    
    // MARK: - Data manipulation - insert and delete support
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellEditable {
            object.commitEditing?(editingStyle)
        }
    }
    
    // MARK: - Data manipulation - reorder / moving support
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let object = self.cellModel(at: sourceIndexPath) as? StructuredCellMovable {
            object.didMove?(sourceIndexPath, destinationIndexPath)
        }
    }
    
}

extension TableStructuredController: UITableViewDelegate {
    
    // MARK: - Will Display
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableViewDelegate?.responds(to: #selector(tableView(_:willDisplay:forRowAt:))) == true {
            tableViewDelegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
        } else if let object = self.cellModel(at: indexPath) as? StructuredViewDisplayable {
            object.willDisplay?(cell)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if tableViewDelegate?.responds(to: #selector(tableView(_:willDisplayHeaderView:forSection:))) == true {
            tableViewDelegate?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
        } else if let header = structure[section].header {
            switch header {
            case .view(let viewModel):
                if let viewModel = viewModel as? StructuredViewDisplayable {
                    viewModel.willDisplay?(view)
                }
            default:
                return
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = structure[section].footer else { return }
        switch footer {
        case .view(let viewModel):
            if let viewModel = viewModel as? StructuredViewDisplayable {
                viewModel.willDisplay?(view)
            }
        default:
            return
        }
    }
    
    // MARK: - Did End Display
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredViewDisplayable {
            object.didEndDisplay?(cell)
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let header = structure[section].header else { return }
        switch header {
        case .view(let viewModel):
            if let viewModel = viewModel as? StructuredViewDisplayable {
                viewModel.didEndDisplay?(view)
            }
        default:
            return
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let footer = structure[section].footer else { return }
        switch footer {
        case .view(let viewModel):
            if let viewModel = viewModel as? StructuredViewDisplayable {
                viewModel.didEndDisplay?(view)
            }
        default:
            return
        }
    }
    
    // MARK: - Height
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let object = self.cellModel(at: indexPath) as? StructuredViewHeight {
            return object.height(for: tableView)
        } else {
            return tableView.rowHeight
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let header = structure[section].header else {
            return tableView.sectionHeaderHeight
        }
        switch header {
        case .text:
            return tableView.sectionHeaderHeight
        case .view(let viewModel):
            if let viewModel = viewModel as? StructuredViewHeight {
                return viewModel.height(for: tableView)
            } else {
                return tableView.sectionHeaderHeight
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let footer = structure[section].footer else {
            return tableView.sectionFooterHeight
        }
        switch footer {
        case .text:
            return tableView.sectionFooterHeight
        case .view(let viewModel):
            if let viewModel = viewModel as? StructuredViewHeight {
                return viewModel.height(for: tableView)
            } else {
                return tableView.sectionFooterHeight
            }
        }
    }
    
    // MARK: - Estimated Height
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let object = self.cellModel(at: indexPath) as? StructuredViewEstimatedHeight {
            return object.estimatedHeight(for: tableView)
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard let header = structure[section].header else {
            return tableView.estimatedSectionFooterHeight
        }
        switch header {
        case .text:
            return tableView.estimatedSectionFooterHeight
        case .view(let viewModel):
            if let viewModel = viewModel as? StructuredViewEstimatedHeight {
                return viewModel.estimatedHeight(for: tableView)
            } else {
                return tableView.estimatedSectionFooterHeight
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        guard let footer = structure[section].footer else {
            return tableView.estimatedSectionFooterHeight
        }
        switch footer {
        case .text:
            return tableView.estimatedSectionFooterHeight
        case .view(let viewModel):
            if let viewModel = viewModel as? StructuredViewEstimatedHeight {
                return viewModel.estimatedHeight(for: tableView)
            } else {
                return tableView.estimatedSectionFooterHeight
            }
        }
    }
    
    // MARK: - Header/Footer Views
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = structure[section].header else { return nil }
        switch header {
        case .view(let viewModel):
            let identifier = type(of: viewModel).reuseIdentifier(for: .tableView(tableView))
            if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
                viewModel.configureAny(view: view, isUpdating: false)
                return view
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = structure[section].footer else { return nil }
        switch footer {
        case .view(let viewModel):
            let identifier = type(of: viewModel).reuseIdentifier(for: .tableView(tableView))
            if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
                viewModel.configureAny(view: view, isUpdating: false)
                return view
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    // MARK: - Accessory Button
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellAccessoryButtonTappable {
            let cell = tableView.cellForRow(at: indexPath)
            object.accessoryButtonTapped?(cell)
        }
    }
    
    // MARK: - Selection
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let object = self.cellModel(at: indexPath) as? StructuredCellSelectable, let willSelect = object.willSelect {
            let cell = tableView.cellForRow(at: indexPath)
            return willSelect(cell)
        } else {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let object = self.cellModel(at: indexPath) as? StructuredCellSelectable, let willDeselect = object.willDeselect {
            let cell = tableView.cellForRow(at: indexPath)
            return willDeselect(cell)
        } else {
            return nil
        }
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellSelectable, let cell = tableView.cellForRow(at: indexPath) {
            if let deselectAnimation = object.didSelect?(cell) {
                tableView.deselectRow(at: indexPath, animated: deselectAnimation)
            }
        }
    }
        
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellSelectable, let didDeselect = object.didDeselect  {
            let cell = tableView.cellForRow(at: indexPath)
            didDeselect(cell)
        }
    }
    
    // MARK: - Editing
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if let object = self.cellModel(at: indexPath) as? StructuredCellEditable {
            return object.editingStyle
        }
        return .none
    }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if let object = self.cellModel(at: indexPath) as? StructuredCellDeletable {
            return object.titleForDeleteConfirmationButton
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if let object = self.cellModel(at: indexPath) as? StructuredCellEditable {
            return object.shouldIndentWhileEditing
        }
        return true
    }
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellEditable {
            object.willBeginEditing?()
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        if let object = self.cellModel(at: indexPath) as? StructuredCellEditable {
            object.didEndEditing?()
        }
    }
    
    // MARK: - Swipe
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let object = self.cellModel(at: indexPath) as? StructuredCellSwipable {
            return object.leadingSwipeActions
        }
        return nil
    }

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let object = self.cellModel(at: indexPath) as? StructuredCellSwipable {
            return object.trailingSwipeActions
        }
        return nil
    }
    
    // MARK: - Moving
    
//    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//
//    }
    
    // MARK: - Indention
    
//    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
//
//    }

    
    // MARK: - Focus
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if let object = self.cellModel(at: indexPath) as? StructuredCellFocusable {
            return object.canFocus?() ?? false
        }
        return false
    }
    
//    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
//
//    }
    
//    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//
//    }
    
//    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
//        
//    }
    
    // MARK: - Spring Loading
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        if let object = self.cellModel(at: indexPath) as? StructuredCellSpringLoadable {
            return object.shouldSpringLoad?(context) ?? false
        }
        return false
    }
    
    // MARK: - Multiple Selection
    
    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        if let object = self.cellModel(at: indexPath) as? StructuredCellMultipleSelectable {
            return object.shouldBeginMultipleSelection
        }
        return false
    }
    
    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        if let object = self.cellModel(at: indexPath) as? StructuredCellMultipleSelectable {
            object.didBeginMultipleSelection?()
        }
    }
    
//    @available(iOS 13.0, *)
//    public func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
//
//    }
    
    // MARK: - Contextual menu
    
    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if let object = self.cellModel(at: indexPath) as? StructuredCellContextualMenuConfigurable {
            return object.contextMenuConfiguration?(point)
        }
        return nil
    }
    
//    @available(iOS 13.0, *)
//    public func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//
//    }

//    @available(iOS 13.0, *)
//    public func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//
//    }

//    @available(iOS 13.0, *)
//    public func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
//
//    }
    

    
    
    
    // MARK: - Section Footer
    
    

    
    
    

    
}
