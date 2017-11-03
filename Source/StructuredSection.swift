//
//  TableStructuredSection.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 30/03/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

extension Array where Element: StructuredSection {
    
    func indexPath(of element: StructuredObject) -> IndexPath? {
        for (index, section) in self.enumerated() {
            if let row = section.index(of: element) {
                return IndexPath(row: row, section: index)
            }
        }
        return nil
    }
    
    func contains(structured object: StructuredObject) -> Bool {
        return self.contains(where: { (section) -> Bool in
            return section.rows.contains(object)
        })
    }
    
}

open class StructuredSection: Equatable {
    
    public static func ==(lhs: StructuredSection, rhs: StructuredSection) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.identifier != nil
    }
    
    open var identifier: String?
    
    open var headerTitle: String?
    
    open var footerTitle: String?
    
    open var rows: [StructuredObject] = [] {
        didSet {
            count = rows.count
        }
    }
    
    open var count: Int = 0
    
    open var isEmpty: Bool { return rows.isEmpty }
    
    var isClosed = false
    
    public init(identifier: String?) {
        self.identifier = identifier
    }
    
    open func append<T: Equatable>(_ object: T) {
        if isClosed {
            fatalError("TableCollectionStructured: Section is appended to structue. You can not add rows more.")
        }
        let obj = StructuredObject(value: object)
        rows.append(obj)
    }
    
    open func append<T: Equatable>(contentsOf objects: [T]) {
        if isClosed {
            fatalError("TableCollectionStructured: Section is appended to structue alredy. You can not add rows more.")
        }
        let objs = objects.map({ StructuredObject(value: $0) })
        rows.append(contentsOf: objs)
    }
    
    open subscript(index: Int) -> Any {
        return rows[index].value
    }
    
    func contains(element: StructuredObject) -> Bool {
        return rows.contains(element)
    }
    
    func index(of element: StructuredObject) -> Int? {
        return rows.index(of: element)
    }
    
    open func useIdentifierAsHeaderTitle() {
        headerTitle = identifier
    }
    
}

