//
//  StructuredObject.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 01/11/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

open class StructuredObject: Equatable {
    
    let value: Any
    
    private let equals: (Any) -> Bool
    
    init<T: Equatable>(value: T) {
        
        func isEquals(_ other: Any) -> Bool {
            if let r = other as? T {
                return value == r
            } else {
                return false
            }
        }
        
        self.value = value
        self.equals = isEquals
    }
    
    public static func ==(lhs: StructuredObject, rhs: StructuredObject) -> Bool {
        return lhs.equals(rhs.value)
    }
    
}

