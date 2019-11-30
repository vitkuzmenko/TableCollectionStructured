//
//  StructuredObject.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 01/11/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

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

// MARK: - StructuredViewHeight

public protocol StructuredViewHeight {
    
    func height(for tableView: UITableView) -> CGFloat
    
}

public protocol StructuredViewEstimatedHeight {
    
    func estimatedHeight(for tableView: UITableView) -> CGFloat
    
}

// MARK: - StructuredCellDynamicSize

public protocol StructuredCellDynamicSize {
    
    func size(for parentView: UICollectionView) -> CGSize
    
}

public protocol StructuredCellAccessoryButtonTappable {
    
    typealias AccessoryButtonTappedAction = (UITableViewCell?) -> Void
    
    var accessoryButtonTapped: AccessoryButtonTappedAction? { get }
    
}

public protocol StructuredCellHighlightable {
    
    var shouldHighlightRow: Bool { get }
    
    typealias DidHighlightRow = () -> Void
    
    var didHighlightRow: DidHighlightRow? { get }
    
    typealias DidUnhighlightRow = () -> Void
    
    var didUnhighlightRow: DidUnhighlightRow? { get }
    
}

// MARK: - StructuredCellSelectable

public protocol StructuredCellSelectable {
    
    typealias WillSelect = (UIView?) -> IndexPath?
    
    typealias WillDeselect = (UIView?) -> IndexPath?
    
    /// return nil -> no deselction. return true -> deselect animted. return false -> deselect without animation
    typealias DidSelect = (UIView?) -> Bool?
    
    typealias DidDeselect = (UIView?) -> Void
    
    var willSelect: WillSelect? { get }
    
    var willDeselect: WillDeselect? { get }
    
    var didSelect: DidSelect? { get }
    
    var didDeselect: DidDeselect? { get }
    
}

public extension StructuredCellSelectable {
    
    var willSelect: WillSelect? {
        return nil
    }
    
    var willDeselect: WillDeselect? {
        return nil
    }
    
    var didDeselect: DidSelect? {
        return nil
    }
    
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

// MARK: - StructuredViewWillDisplay

public protocol StructuredViewWillDisplay {
    
    typealias WillDisplay = (UIView) -> Void
    
    var willDisplay: WillDisplay? { get }
    
}

// MARK: - StructuredViewDidEndDisplay

public protocol StructuredViewDidEndDisplay {
    
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
