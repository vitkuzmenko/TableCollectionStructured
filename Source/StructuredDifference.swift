//
//  StructuredDifference.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 01/11/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

class StructuredDifference {
    
    enum DifferenceError: Error, LocalizedError {
        
        case insertion, deletion, similarObjects, similarSections
        
        var errorDescription: String? {
            switch self {
            case .insertion:
                return "Attempts to insert row in movable section."
            case .deletion:
                return "Attempts to delete row in movable section."
            case .similarSections:
                return "Structure contains two or more equal section identifiers."
            case .similarObjects:
                return "Structure contains two or more equal objects."
            }
        }
    }
    
    var sectionsToMove: [(from: Int, to: Int)] = []
    
    var sectionsToDelete = IndexSet()
    
    var sectionsToInsert = IndexSet()
    
    var rowsToMove: [(from: IndexPath, to: IndexPath)] = []
    
    var rowsToDelete: [IndexPath] = []
    
    var rowsToInsert: [IndexPath] = []
    
    var rowsToReload: [IndexPath] = []
    
    init(from oldStructure: [StructuredSectionComarable], to newStructure: [StructuredSectionComarable]) throws {
        
        for (oldSectionIndex, oldSection) in oldStructure.enumerated() {
            
            if let newSectionIndex = newStructure.firstIndex(where: { $0.identifier == oldSection.identifier }) {
                if oldSectionIndex != newSectionIndex {
                    sectionsToMove.append((from: oldSectionIndex, to: newSectionIndex))
                }
            } else {
                sectionsToDelete.insert(oldSectionIndex)
            }
            
            for (oldRowIndex, row) in oldSection.rows.enumerated() {
                let oldIndexPath = IndexPath(row: oldRowIndex, section: oldSectionIndex)
                if let newRowIndexPath = newStructure.indexPath(of: row) {
                    if oldIndexPath != newRowIndexPath {
                        if newStructure.contains(where: { $0.identifier == oldSection.identifier }) {
                            let newSection = newStructure[newRowIndexPath.section]
                            if oldStructure.contains(where: { $0.identifier == newSection.identifier }) {
                                rowsToMove.append((from: oldIndexPath, to: newRowIndexPath))
                            } else {
                                rowsToDelete.append(oldIndexPath)
                            }
                        } else {
                            rowsToInsert.append(newRowIndexPath)
                        }
                    }
                } else {
                    rowsToDelete.append(oldIndexPath)
                }
            }
        }
        
        for (newSectionIndex, newSection) in newStructure.enumerated() {
            if !oldStructure.contains(where: { $0.identifier == newSection.identifier }) {
                sectionsToInsert.insert(newSectionIndex)
            }
            
            for (newRowIndex, newRow) in newSection.rows.enumerated() {
                if !oldStructure.contains(structured: newRow) {
                    rowsToInsert.append(IndexPath(row: newRowIndex, section: newSectionIndex))
                }
            }
        }
        
        if rowsToDelete.contains(where: { (deletion) -> Bool in
            return sectionsToMove.contains(where: { (movement) -> Bool in
                return movement.from == deletion.section
            })
        }) {
            throw DifferenceError.deletion
        }

        if rowsToInsert.contains(where: { (insertion) -> Bool in
            return sectionsToMove.contains(where: { (movement) -> Bool in
                return movement.to == insertion.section
            })
        }) {
            throw DifferenceError.insertion
        }
        
        var uniqueSections: [StructuredSectionComarable] = []
        
        for newSection in newStructure {
            if uniqueSections.contains(where: { $0.identifier == newSection.identifier }) {
                throw DifferenceError.similarSections
            } else {
                uniqueSections.append(newSection)
            }
        }
        
        var unique: [StructuredCellComparable] = []
        
        for section in newStructure {
            for newRow in section.rows {
                if unique.contains(where: { $0.identifier == newRow.identifier }) {
                    throw DifferenceError.similarObjects
                } else {
                    unique.append(newRow)
                }
            }
        }
    }
    
}

