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

public protocol StructuredCell {
    
    func reuseIdentifier(for parentView: StructuredView) -> String
    
    func configureAny(cell: UIView)
    
    func isEqual(_ object: Any?) -> Bool
}

public protocol StructuredCellConfigurable: StructuredCell {
    
    associatedtype CellType: UIView
    
    func configure(cell: CellType)
    
}

public extension StructuredCellConfigurable {
    
    //    public var reuseIdentifier: String {
    //        return String(describing: CellType.self).components(separatedBy: ".").last!
    //    }
    
    public func configureAny(cell: UIView) {
        if let cell = cell as? CellType {
            configure(cell: cell)
        } else {
            assertionFailure("StructuredCellConfigurable and be implemet UIView and subclass only")
        }
    }
    
}

public protocol StructuredCellDynamicHeight {
    
    func height(for parentView: UIView) -> CGFloat
    
}

public protocol StructuredCellDynamicSize {
    
    func size(for parentView: UIView) -> CGSize
    
}

public protocol StructuredCellSelectable {
    
    typealias DidSelect = (UIView) -> Bool
    
    var didSelect: DidSelect? { get }
    
}

public protocol StructuredCellDeselectable {
    
    typealias DidDeselect = () -> Void
    
    var didDeselect: DidDeselect? { get }
    
}

public protocol StructuredCellWillDisplay {
    
    typealias WillDisplay = () -> Void
    
    var willDisplay: WillDisplay? { get }
    
}

public protocol StructuredCellDidEndDisplay {
    
    typealias DidEndDisplay = () -> Void
    
    var didEndDisplay: DidEndDisplay? { get }
    
}

open class StructuredObject: Equatable {
    
    public let value: Any
    
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
