//
//  TableStructuredSection.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 30/03/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation


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
            
            if let row = firstIndex, let cellModel = section.rows[index] as? StructuredCellIdentifable {
                return (IndexPath(row: row, section: index), cellModel)
            }
        }
        return nil
    }
    
    func contains(structured identifyHasher: Hasher, structuredView: StructuredView) -> Bool {
        return indexPath(of: identifyHasher, structuredView: structuredView) != nil
    }
    
}

extension Sequence where Iterator.Element == StructuredSectionOld {
    
    func indexPath(of identifyHasher: Hasher) -> IndexPath? {
        for (index, section) in enumerated() {
                        
            let firstIndex = section.rows.firstIndex { rhs -> Bool in
                guard let rhsIdentifyHasher = rhs.identifyHasher else { return false }
                return identifyHasher.finalize() == rhsIdentifyHasher.finalize()
            }
            
            if let row = firstIndex {
                return IndexPath(row: row, section: index)
            }
        }
        return nil
    }
    
    func contains(structured identifyHasher: Hasher) -> Bool {
        return indexPath(of: identifyHasher) != nil
    }
    
}

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

extension StructuredSection: Hashable {
    
    public static func == (lhs: StructuredSection, rhs: StructuredSection) -> Bool {
        return lhs.identifier == rhs.identifier
    }
        
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}

struct StructuredSectionOld {
    
    let identifier: AnyHashable
    
    let rows: [StructuredCellOld]
    
}

extension StructuredSectionOld: Equatable {
    static func == (lhs: StructuredSectionOld, rhs: StructuredSectionOld) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
