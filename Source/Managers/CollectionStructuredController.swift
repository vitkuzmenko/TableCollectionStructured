//
//  structuredController.swift
//  Tablestructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

public protocol CollectionStructuredViewController: class {
    var collectionView: UICollectionView! { get set }
}

public enum CollectionViewReloadRule {
    case none, animated, noAnimation
}

open class CollectionStructuredController<ViewController: CollectionStructuredViewController>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    open weak var collectionView: UICollectionView!
    
    open weak var vc: ViewController!
    
    open var structure: [StructuredSection] = []
    
    private var previousStructure: [StructuredSection] = []
    
    public convenience init(vc: ViewController) {
        self.init()
        collectionView = vc.collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        self.vc = vc
        
        configureCollectionView()
    }
    
    open func indexPath<T: StructuredCell>(for object: T) -> IndexPath? {
        let obj = StructuredObject(value: object)
        return structure.indexPath(of: obj)
    }
    
    open func object(at indexPath: IndexPath) -> Any {
        return structure[indexPath.section][indexPath.row]
    }
    
    open func set(structure: [StructuredSection], rule: CollectionViewReloadRule = .noAnimation) {
        beginBuilding()
        self.structure = structure
        buildStructure(rule: rule)
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
        structure.append(section)
    }
    
    open func append(section: inout StructuredSection, new identifier: String? = nil) {
        append(section: section)
        section = StructuredSection(identifier: identifier)
    }
    
    open func configureCollectionView() {
        
    }
    
    open func buildStructure(rule: CollectionViewReloadRule = .noAnimation) {
        switch rule {
        case .none:
            break
        case .animated:
            self.performReload()
        case .noAnimation:
            self.reloadData()
        }
    }
    
    open func reloadData() {
        collectionView.reloadData()
    }
    
    open func performReload(completion: ((Bool) -> Void)? = nil) {
        
        let diff = StructuredDifference(from: previousStructure, to: structure)
        
        if !diff.reloadConstraint.isEmpty || collectionView.window == nil {
            return reloadData()
        }
        
        collectionView.performBatchUpdates({
            
            for movement in diff.sectionsToMove {
                self.collectionView.moveSection(movement.from, toSection: movement.to)
            }
            
            self.collectionView.deleteSections(diff.sectionsToDelete)
            
            self.collectionView.insertSections(diff.sectionsToInsert)
            
            for movement in diff.rowsToMove {
                self.collectionView.moveItem(at: movement.from, to: movement.to)
            }
            
            self.collectionView.deleteItems(at: diff.rowsToDelete)
            
            self.collectionView.insertItems(at: diff.rowsToInsert)
            
        }, completion: { [weak self] f in
            self?.collectionView?.reloadData()
            completion?(f)
        })
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return structure.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return structure[section].count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = object(at: indexPath) as? StructuredCell else { fatalError("Model should be StructuredCellModelProtocol") }
        return collectionView.dequeueReusableCell(withModel: model, for: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, reuseIdentifierFor object: Any) -> String? {
        var identifier: String?
        if let object = object as? String {
            identifier = object
        }
        return identifier
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    open func collectionView(_ collectionView: UICollectionView, configure cell: UICollectionViewCell, for object: Any, at indexPath: IndexPath) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let object = self.object(at: indexPath) as? StructuredCellWillDisplay {
            object.willDisplay?()
        }
    }
    
    @available(*, deprecated, message: "")
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, for object: Any, forItemAt indexPath: IndexPath) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? StructuredCellDidEndDisplay {
            cell.didEndDisplay?()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let object = self.object(at: indexPath) as? StructuredCellDynamicSize {
            return object.size(for: collectionView)
        } else {
            return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeFor object: Any, at: IndexPath) -> CGSize {
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let object = self.object(at: indexPath) as? StructuredCellSelectable, let cell = collectionView.cellForItem(at: indexPath) {
            _ = object.didSelect?(cell)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectCell identifier: String, object: Any, at indexPath: IndexPath) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        return proposedIndexPath
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

