//
//  TableStructuredSection.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 30/03/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

public struct StructuredSection {
    
    public let identifier: AnyHashable
    
    public var headerTitle: String?
    
    public var footerTitle: String?
    
    public var rows: [StructuredCell] = [] {
        didSet {
            count = rows.count
        }
    }
    
    public var count: Int = 0
    
    public var isEmpty: Bool { return rows.isEmpty }
    
    public init(identifier: AnyHashable, rows: [StructuredCell] = []) {
        self.identifier = identifier
        self.rows = rows
        self.count = rows.count
    }
    
    public mutating func append(_ object: StructuredCell) {
        rows.append(object)
    }
    
    public mutating func append(contentsOf objects: [StructuredCell]) {
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

extension Sequence where Iterator.Element == StructuredSection {
    
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
    
    // MARK: - Converting to old strcuture
    
    func old(for structuredView: StructuredView) -> [StructuredSectionOld] {
        return map { oldSection -> StructuredSectionOld in
            return StructuredSectionOld(identifier: oldSection.identifier, rows: oldSection.rows.map { cellOld in
                return StructuredCellOld(
                    identifyHasher: (cellOld as? StructuredCellIdentifable)?.identifyHasher(for: structuredView),
                    contentHasher: (cellOld as? StructuredCellContentIdentifable)?.contentHasher()
                )
            })
        }
    }
    
}


