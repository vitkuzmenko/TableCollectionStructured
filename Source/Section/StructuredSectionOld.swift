//
//  StructuredSectionOld.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 29.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

struct StructuredSectionOld {
    
    let identifier: AnyHashable
    
    let rows: [StructuredCellOld]
    
    let headerContentHasher: Hasher?
    
    let footerContentHasher: Hasher?
    
}

extension StructuredSectionOld: Equatable {
    static func == (lhs: StructuredSectionOld, rhs: StructuredSectionOld) -> Bool {
        return lhs.identifier == rhs.identifier
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
