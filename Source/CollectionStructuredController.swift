//
//  CollectionStructuredController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

open class CollectionStructuredController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet open weak var collectionView: UICollectionView!
    
    open var collectionStructure: [[Any]] = []
    
    open func indexPathForObject(object: Any) -> IndexPath? {
        var _section = 0
        for section in collectionStructure {
            var row = 0
            for _object in section {
                if let _s = _object as? String, let s = object as? String, _s == s {
                    return IndexPath(row: row, section: _section)
                } else if object as AnyObject === _object as AnyObject {
                    return IndexPath(row: row, section: _section)
                }
                row += 1
            }
            _section += 1
        }
        return nil
    }
    
    open func collectionStructureObjectAt(indexPath: IndexPath) -> Any {
        return collectionStructure[indexPath.section][indexPath.row]
    }
    
    
    open func beginBuilding() {
        collectionStructure = []
    }
    
    open func newSection() -> [Any] {
        return []
    }
    
    open func append(section: inout [Any]) {
        collectionStructure.append(section)
        section = []
    }
    
    open func configureCollectionView() {
        
    }
    
    open func buildCollectionViewStructure(reloadData: Bool) {
        if reloadData {
            collectionView.reloadData()
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionStructure.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionStructure[section].count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object = collectionStructureObjectAt(indexPath: indexPath)
        guard let identifier = self.collectionView(collectionView, reuseIdentifierFor: object) else {
            assert(false, "No reuse identifier")
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
    
    open func collectionView(_ collectionView: UICollectionView, configure cell: UICollectionViewCell, for object: Any, at indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let object = collectionStructureObjectAt(indexPath: indexPath)
        self.collectionView(collectionView, willDisplay: cell, for: object, forItemAt: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, for object: Any, forItemAt indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let identifier = cell!.reuseIdentifier!
        let object = collectionStructureObjectAt(indexPath: indexPath)
        self.collectionView(collectionView, didSelectCell: identifier, object: object, at: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectCell identifier: String, object: Any, at indexPath: IndexPath) {
        
    }
    
}

