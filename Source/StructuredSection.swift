//
//  TableStructuredSection.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 30/03/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation


extension Sequence where Iterator.Element == StructuredSectionComarable {
    
    func indexPath(of lhs: StructuredCellComparable) -> IndexPath? {
        for (index, section) in enumerated() {
                        
            let firstIndex = section.rows.firstIndex { rhs -> Bool in
                return lhs.identifyHasher.finalize() == rhs.identifyHasher.finalize()
            }
            
            if let row = firstIndex {
                return IndexPath(row: row, section: index)
            }
        }
        return nil
    }
    
    func contains(structured element: StructuredCellComparable) -> Bool {
        return indexPath(of: element) != nil
    }
    
}

open class StructuredSection: StructuredSectionComarable {
    
    public let identifier: AnyHashable
    
    open var headerTitle: String?
    
    open var footerTitle: String?
    
    open var rows: [StructuredCellComparable] = [] {
        didSet {
            count = rows.count
        }
    }
    
    open var count: Int = 0
    
    open var isEmpty: Bool { return rows.isEmpty }
    
    var isClosed = false
    
    public init(identifier: AnyHashable) {
        self.identifier = identifier
    }
    
    public init(identifier: AnyHashable, rows: [StructuredCellComparable]) {
        self.identifier = identifier
        self.rows = rows
    }
    
    open func append(_ object: StructuredCellComparable) {
        if isClosed {
            fatalError("TableCollectionStructured: Section is appended to structue. You can not add rows more.")
        }
        rows.append(object)
    }
    
    open func append(contentsOf objects: [StructuredCellComparable]) {
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

public protocol StructuredSectionComarable {
    var identifier: AnyHashable { get }
    var rows: [StructuredCellComparable] { get }
}



struct StructuredSectionOld: StructuredSectionComarable {
    
    let identifier: AnyHashable
    
    let rows: [StructuredCellComparable]
    
}

extension StructuredSectionOld: Equatable {
    static func == (lhs: StructuredSectionOld, rhs: StructuredSectionOld) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
