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
    }

    open func indexPath<T: Equatable>(for object: T) -> IndexPath? {
        let obj = StructuredObject(value: object)
        return structure.indexPath(of: obj)
    }

    open func object(at indexPath: IndexPath) -> Any {
        return structure[indexPath.section][indexPath.row]
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

    open func buildStructure(reloadData: Bool = true) {
        if reloadData {
            self.performReload()
        }
    }
    
    open func reloadData() {
        collectionView.reloadData()
    }
    
    open func performReload(completion: ((Bool) -> Void)? = nil) {
        
        if structure.contains(where: { (section) -> Bool in
            return section.identifier == nil
        }) {
            NSLog("TableCollectionStructured: Can not reload animated. One or more section is not contains identifier.")
            return reloadData()
        }
        
        let diff = StructuredDifference(from: previousStructure, to: structure)
        
        if diff.canNotReloadAnimated {
            NSLog("TableCollectionStructured: Can not reload animated. Attempts to delete or insert row in movable section.")
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

        }, completion: completion)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return structure.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return structure[section].count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object = self.object(at: indexPath)
        guard let identifier = self.collectionView(collectionView, reuseIdentifierFor: object) else {
            assert(false, "TableCollectionStructured: Reuse identifier for this object is not configured in collectionView(_:reuseIdentifierFor:)")
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        self.collectionView(collectionView, configure: cell, for: object, at: indexPath)
        return cell
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

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let object = self.object(at: indexPath)
        self.collectionView(collectionView, willDisplay: cell, for: object, forItemAt: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, for object: Any, forItemAt indexPath: IndexPath) {

    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let object = self.object(at: indexPath)
        return self.collectionView(collectionView, layout: collectionViewLayout, sizeFor: object, at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeFor object: Any, at: IndexPath) -> CGSize {
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let identifier = cell!.reuseIdentifier!
        let object = self.object(at: indexPath)
        self.collectionView(collectionView, didSelectCell: identifier, object: object, at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectCell identifier: String, object: Any, at indexPath: IndexPath) {

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

