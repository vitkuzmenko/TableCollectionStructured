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


public protocol StructuredCellContentIdentifable {
    
    func contentHash(into hasher: inout Hasher)
    
}

public protocol StructuredCell {
    
    static func reuseIdentifier(for parentView: StructuredView) -> String
    
    func configureAny(cell: UIView)
    
}

public struct StructuredCellOld {
    
    public let identifyHasher: Hasher?
    
    public let contentHasher: Hasher?
    
}

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
