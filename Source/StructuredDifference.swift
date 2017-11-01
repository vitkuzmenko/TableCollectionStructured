//
//  StructuredDifference.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 01/11/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

class StructuredDifference {
    
    var sectionsToMove: [(from: Int, to: Int)] = []
    
    var sectionsToDelete = IndexSet()
    
    var sectionsToInsert = IndexSet()
    
    var rowsToMove: [(from: IndexPath, to: IndexPath)] = []
    
    var rowsToDelete: [IndexPath] = []
    
    var rowsToInsert: [IndexPath] = []
    
    var canNotReloadAnimated = false
    
    init(from previousStructure: [StructuredSection], to newStructure: [StructuredSection]) {
        
        for (previousSectionIndex, section) in previousStructure.enumerated() {
            
            if let newSectionIndex = newStructure.index(of: section) {
                if previousSectionIndex != newSectionIndex {
                    sectionsToMove.append((from: previousSectionIndex, to: newSectionIndex))
                }
            } else {
                sectionsToDelete.insert(previousSectionIndex)
            }
            
            for (previousRowIndex, row) in section.rows.enumerated() {
                let previousIndexPath = IndexPath(row: previousRowIndex, section: previousSectionIndex)
                if let newRowIndexPath = newStructure.indexPath(of: row) {
                    if previousIndexPath != newRowIndexPath {
                        if newStructure.contains(section) {
                            let newSection = newStructure[newRowIndexPath.section]
                            if previousStructure.contains(newSection) {
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
        
        for (newSectionIndex, section) in newStructure.enumerated() {
            if !previousStructure.contains(section) {
                sectionsToInsert.insert(newSectionIndex)
            }
            
            for (newRowIndex, row) in section.rows.enumerated() {
                if !previousStructure.contains(structured: row) {
                    rowsToInsert.append(IndexPath(row: newRowIndex, section: newSectionIndex))
                }
            }
        }
        
        canNotReloadAnimated = rowsToDelete.contains(where: { (deletion) -> Bool in
            return sectionsToMove.contains(where: { (movement) -> Bool in
                return movement.from == deletion.section
            })
        }) || rowsToInsert.contains(where: { (insertion) -> Bool in
            return sectionsToMove.contains(where: { (movement) -> Bool in
                return movement.to == insertion.section
            })
        })
    }
    
}
