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

public protocol StructuredCellComparable {
    
    var identifyHashable: AnyHashable? { get }
    
    var identifyHasher: Hasher? { get set }
    
}

public protocol StructuredCell: StructuredCellComparable {
    
    static func reuseIdentifier(for parentView: StructuredView) -> String
    
    func configureAny(cell: UIView)
    
    mutating func makeIdentifyHasher()
    
}

extension StructuredCell {
    
    mutating func makeIdentifyHasher() {
        var hasher = Hasher()
        hasher.combine(type(of: self).reuseIdentifier(for: .tableView))
        hasher.combine(type(of: self).reuseIdentifier(for: .collectionView))
        hasher.combine(identifyHashable)
        identifyHasher = hasher
    }
    
}

public struct StructuredCellOld {
    
    public var identifyHasher: Hasher?
    
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
    
    typealias DidDeselect = (UIView?) -> Void
    
    var didDeselect: DidDeselect? { get }
    
}

public protocol StructuredCellEditable {
    
    typealias CanEdit = () -> Bool
    
    var canEdit: CanEdit? { get }
    
    typealias EditingStyle = () -> UITableViewCell.EditingStyle
    
    var editingStyle: EditingStyle? { get }
    
    typealias CommitEditing = (UITableViewCell.EditingStyle) -> Void
    
    var commitEditing: CommitEditing? { get }
    
}


public protocol StructuredCellWillDisplay {
    
    typealias WillDisplay = (UIView) -> Void
    
    var willDisplay: WillDisplay? { get }
    
}

public protocol StructuredCellDidEndDisplay {
    
    typealias DidEndDisplay = (UIView) -> Void
    
    var didEndDisplay: DidEndDisplay? { get }
    
}

public protocol StructuredCellMovable {
    
    typealias CanMove = () -> Bool
    
    var canMove: CanMove? { get }
    
    typealias DidMove = (IndexPath, IndexPath) -> Void
    
    var didMove: DidMove? { get }
    
}

public protocol StructuredCellFocusable {
    
    typealias CanFocus = () -> Bool
    
    var canFocus: CanFocus? { get }
    
}

public protocol StructuredCellInvalidatable {
    func invalidated()
}
