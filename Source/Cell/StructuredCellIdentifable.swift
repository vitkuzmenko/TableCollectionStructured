//
//  StructuredCellIdentifable.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 29.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

public protocol StructuredCellIdentifable {

    func identifyHash(into hasher: inout Hasher)
    
}

extension StructuredCellIdentifable {
    
    internal func identifyHasher(for structuredView: StructuredView) -> Hasher {
        var hasher = Hasher()
        let cell = self as! StructuredCell
        hasher.combine(type(of: cell).reuseIdentifier(for: structuredView))
        identifyHash(into: &hasher)
        return hasher
    }
    
}

