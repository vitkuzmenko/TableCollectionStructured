//
//  StructuredObject.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 01/11/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

public enum StructuredView {
    case tableView, collectionView
}

public protocol StructuredCell: StructuredCellComparable {
    
    func reuseIdentifier(for parentView: StructuredView) -> String
    
    func configureAny(cell: UIView)
    
}

public struct StructuredCellOld: StructuredCellComparable {
    
    public let identifier: AnyHashable
    
}

public protocol StructuredCellConfigurable: StructuredCell {
    
    associatedtype CellType: UIView
    
    func configure(cell: CellType)
    
}

public extension StructuredCellConfigurable {
    
    func configureAny(cell: UIView) {
        if let cell = cell as? CellType {
            configure(cell: cell)
        } else {
            assertionFailure("StructuredCellConfigurable and be implemet UIView and subclass only")
        }
    }
    
}

public protocol StructuredCellDynamicHeight {
    
    func height(for parentView: UITableView) -> CGFloat
    
}

public protocol StructuredCellDynamicSize {
    
    func size(for parentView: UICollectionView) -> CGSize
    
}

public protocol StructuredCellSelectable {
    
    typealias DidSelect = (UIView) -> Bool
    
    var didSelect: DidSelect? { get }
    
}

public protocol StructuredCellDeselectable {
    
    typealias DidDeselect = (UIView) -> Void
    
    var didDeselect: DidDeselect? { get }
    
}

public protocol StructuredCellWillDisplay {
    
    typealias WillDisplay = (UIView) -> Void
    
    var willDisplay: WillDisplay? { get }
    
}

public protocol StructuredCellDidEndDisplay {
    
    typealias DidEndDisplay = (UIView) -> Void
    
    var didEndDisplay: DidEndDisplay? { get }
    
}

public protocol StructuredCellInvalidatable {
    func invalidated()
}

//open class StructuredObject: Equatable {
//
//    public let value: Any
//
//    private let equals: (Any) -> Bool
//
//    init<T: StructuredCell>(value: T) {
//
//        func isEqual(_ other: Any) -> Bool {
//            if let r = other as? T {
//                return value.isEqual(r)
//            } else {
//                return false
//            }
//        }
//
//        self.value = value
//        self.equals = isEqual
//    }
//
//    public static func ==(lhs: StructuredObject, rhs: StructuredObject) -> Bool {
//        return lhs.equals(rhs.value)
//    }
//
//}
//

