//
//  TableStructuredSection.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 30/03/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

open class StructuredSection {
    
    public let identifier: AnyHashable
    
    open var headerTitle: String?
    
    open var footerTitle: String?
    
    open var rows: [StructuredCell] = [] {
        didSet {
            count = rows.count
        }
    }
    
    open var count: Int = 0
    
    open var isEmpty: Bool { return rows.isEmpty }
    
    var isClosed = false
    
    public init(identifier: AnyHashable, rows: [StructuredCell] = []) {
        self.identifier = identifier
        self.rows = rows
        self.count = rows.count
    }
    
    open func append(_ object: StructuredCell) {
        if isClosed {
            fatalError("TableCollectionStructured: Section is appended to structue. You can not add rows more.")
        }
        rows.append(object)
    }
    
    open func append(contentsOf objects: [StructuredCell]) {
        if isClosed {
            fatalError("TableCollectionStructured: Section is appended to structue alredy. You can not add rows more.")
        }
        rows.append(contentsOf: objects)
    }
        
}

extension StructuredSection: Equatable {
    
    public static func == (lhs: StructuredSection, rhs: StructuredSection) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}

extension StructuredSection: Hashable {
        
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}

extension Array where Element == StructuredSection {
    
    func indexPath(of identifyHasher: Hasher, structuredView: StructuredView) -> (indexPath: IndexPath, cellModel: StructuredCellIdentifable)? {
        for (index, section) in enumerated() {
                        
            let firstIndex = section.rows.firstIndex { rhs -> Bool in
                guard let rhsIdentifable = rhs as? StructuredCellIdentifable else {
                    return false
                }
                
                let rhsIdentifyHasher = rhsIdentifable.identifyHasher(for: structuredView)
                return identifyHasher.finalize() == rhsIdentifyHasher.finalize()
            }
            
            if let row = firstIndex, let cellModel = section.rows[row] as? StructuredCellIdentifable {
                return (IndexPath(row: row, section: index), cellModel)
            }
        }
        return nil
    }
    
    func contains(structured identifyHasher: Hasher, structuredView: StructuredView) -> Bool {
        return indexPath(of: identifyHasher, structuredView: structuredView) != nil
    }
    
}
