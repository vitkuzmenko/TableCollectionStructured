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

// MARK: - StructuredCell

public protocol StructuredCell {
    
    static func reuseIdentifier(for parentView: StructuredView) -> String
    
    func configureAny(cell: UIView)
    
}

// MARK: - StructuredTableViewCell

public protocol StructuredTableViewCell: StructuredCell {
    
    associatedtype TableViewCellType: UITableViewCell
    
    static func reuseIdentifierForTableView() -> String
    
    func configure(tableViewCell cell: TableViewCellType)
    
}

public extension StructuredTableViewCell {
    
    static func reuseIdentifier(for parentView: StructuredView) -> String {
        switch parentView {
        case .tableView:
            return reuseIdentifierForTableView()
        default:
            fatalError()
        }
    }
    
    func configureAny(cell: UIView) {
        if let cell = cell as? TableViewCellType {
            configure(tableViewCell: cell)
        } else {
            assertionFailure("StructuredTableViewCell: cell should be subclass of UITableViewCell")
        }
    }
    
}

// MARK: - StructuredCollectionViewCell

public protocol StructuredCollectionViewCell: StructuredCell {
    
    associatedtype CollectionViewCellType: UICollectionViewCell
    
    func reuseIdentifierForCollectionView() -> String
    
    func configure(collectionViewCell cell: CollectionViewCellType)
    
}

public extension StructuredCollectionViewCell {
    
    func reuseIdentifier(for parentView: StructuredView) -> String {
        switch parentView {
        case .collectionView:
            return reuseIdentifierForCollectionView()
        default:
            fatalError()
        }
    }
    
    func configureAny(cell: UIView) {
        if let cell = cell as? CollectionViewCellType {
            configure(collectionViewCell: cell)
        } else {
            assertionFailure("StructuredTableViewCell: cell should be subclass of UICollectionViewCell")
        }
    }
    
}

// MARK: - StructuredCellIdentifable

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

// MARK: - StructuredCellContentIdentifable

public protocol StructuredCellContentIdentifable {
    
    func contentHash(into hasher: inout Hasher)
    
}

extension StructuredCellContentIdentifable {
    
    internal func contentHasher() -> Hasher {
        var hasher = Hasher()
        contentHash(into: &hasher)
        return hasher
    }
    
}

// MARK: - StructuredCellDynamicHeight

public protocol StructuredCellDynamicHeight {
    
    func height(for parentView: UITableView) -> CGFloat
    
}

// MARK: - StructuredCellDynamicSize

public protocol StructuredCellDynamicSize {
    
    func size(for parentView: UICollectionView) -> CGSize
    
}

// MARK: - StructuredCellSelectable

public protocol StructuredCellSelectable {
    
    typealias DidSelect = (UIView) -> Bool
    
    var didSelect: DidSelect? { get }
    
}

// MARK: - StructuredCellDeselectable

public protocol StructuredCellDeselectable {
    
    typealias DidDeselect = (UIView?) -> Void
    
    var didDeselect: DidDeselect? { get }
    
}

// MARK: - StructuredCellEditable

public protocol StructuredCellEditable {
    
    typealias CanEdit = () -> Bool
    
    typealias EditingStyle = () -> UITableViewCell.EditingStyle
    
    typealias CommitEditing = (UITableViewCell.EditingStyle) -> Void
    
    var canEdit: CanEdit? { get }

    var editingStyle: EditingStyle? { get }

    var commitEditing: CommitEditing? { get }
    
}

// MARK: - StructuredCellWillDisplay

public protocol StructuredCellWillDisplay {
    
    typealias WillDisplay = (UIView) -> Void
    
    var willDisplay: WillDisplay? { get }
    
}

// MARK: - StructuredCellDidEndDisplay

public protocol StructuredCellDidEndDisplay {
    
    typealias DidEndDisplay = (UIView) -> Void
    
    var didEndDisplay: DidEndDisplay? { get }
    
}

// MARK: - StructuredCellMovable

public protocol StructuredCellMovable {
    
    typealias CanMove = () -> Bool
    
    typealias DidMove = (IndexPath, IndexPath) -> Void
    
    var canMove: CanMove? { get }
    
    var didMove: DidMove? { get }
    
}

// MARK: - StructuredCellFocusable

public protocol StructuredCellFocusable {
    
    typealias CanFocus = () -> Bool
    
    var canFocus: CanFocus? { get }
    
}

// MARK: - StructuredCellInvalidatable

public protocol StructuredCellInvalidatable {
    func invalidated()
}
