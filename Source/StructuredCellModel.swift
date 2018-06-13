//
//  StructuredObject.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 01/11/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

public protocol StructuredCell {
    
    static var cellAnyType: UIView.Type { get }
    
    func configureAny(cell: UIView)
    
    func isEqual(_ to: Any) -> Bool
}

protocol StructuredCellConfigurable: StructuredCell {
    
    associatedtype CellType: UIView
    
    func configure(cell: CellType)
    
}

extension StructuredCellConfigurable {
    
    static var cellAnyType: UIView.Type {
        return CellType.self
    }
    
    func configureAny(cell: UIView) {
        if let cell = cell as? CellType {
            configure(cell: cell)
        } else {
            assertionFailure("StructuredCellConfigurableModelProtocol and be implemet UIView and subclass only")
        }
    }
    
}

public protocol StructuredCellDynamicHeight: Equatable {
    
    func height(for parentView: UIView) -> CGFloat
    
}

open class StructuredObject: Equatable {
    
    let value: Any
    
    private let equals: (Any) -> Bool
    
    init<T: StructuredCell>(value: T) {
        
        func isEqual(_ other: Any) -> Bool {
            if let r = other as? T {
                return value.isEqual(r)
            } else {
                return false
            }
        }
        
        self.value = value
        self.equals = isEqual
    }
    
    public static func ==(lhs: StructuredObject, rhs: StructuredObject) -> Bool {
        return lhs.equals(rhs.value)
    }
    
}
