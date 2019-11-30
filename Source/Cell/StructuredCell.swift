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

extension StructuredCellSelectable {
    
    public var willSelect: WillSelect? {
        return nil
    }
    
    public var willDeselect: WillDeselect? {
        return nil
    }
    
    public var didDeselect: DidSelect? {
        return nil
    }
    
}

// MARK: - Delete confirmation

public protocol StructuredCellDeletable {
    
    var titleForDeleteConfirmationButton: String? { get }
    
}

// MARK: - Swipe Actions

@available(iOS 11.0, *)
public protocol StructuredCellSwipable {
    
    var leadingSwipeActions: UISwipeActionsConfiguration? { get }
    
    var trailingSwipeActions: UISwipeActionsConfiguration? { get }
    
}

// MARK: - StructuredCellEditable

public protocol StructuredCellEditable {
        
    typealias CommitEditing = (UITableViewCell.EditingStyle) -> Void
    
    typealias WillBeginEditing = () -> Void
    
    typealias DidEndEditing = () -> Void
    
    var canEdit: Bool { get }

    var editingStyle: UITableViewCell.EditingStyle { get }
    
    var shouldIndentWhileEditing: Bool { get }

    var commitEditing: CommitEditing? { get }
    
    var willBeginEditing: WillBeginEditing? { get }
    
    var didEndEditing: DidEndEditing? { get }
    
}

extension StructuredCellEditable {
    
    public var shouldIndentWhileEditing: Bool {
        return true
    }
    
    var willBeginEditing: WillBeginEditing? {
        return nil
    }
    
    var didEndEditing: DidEndEditing? {
        return nil
    }
    
}

// MARK: - StructuredViewWillDisplay

public protocol StructuredViewDisplayable {
    
    typealias WillDisplay = (UIView) -> Void
    
    typealias DidEndDisplay = (UIView) -> Void
    
    var willDisplay: WillDisplay? { get }
    
    var didEndDisplay: DidEndDisplay? { get }
    
}

extension StructuredViewDisplayable {
    
    public var didEndDisplay: DidEndDisplay? {
        return nil
    }
    
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

// MARK: - StructuredCellSpringLoadable

@available(iOS 11.0, *)
public protocol StructuredCellSpringLoadable {
    
    typealias DidBeginMultipleSelection = (UISpringLoadedInteractionContext) -> Bool
    
    var shouldSpringLoad: DidBeginMultipleSelection? { get }
    
}

// MARK: - StructuredCellIndentable

public protocol StructuredCellIndentable {
    
    var indentationLevel: Int { get }
    
}

// MARK: - StructuredCellMultipleSelectable

@available(iOS 13.0, *)
public protocol StructuredCellMultipleSelectable {
    
    typealias DidBeginMultipleSelection = () -> Void
    
    var shouldBeginMultipleSelection: Bool { get }
    
    var didBeginMultipleSelection: DidBeginMultipleSelection? { get }
    
}

// MARK: - StructuredCellContextualMenuConfigurable

@available(iOS 13.0, *)
public protocol StructuredCellContextualMenuConfigurable {
    
    typealias ContextMenuConfiguration = (CGPoint) -> UIContextMenuConfiguration?
    
    var contextMenuConfiguration: ContextMenuConfiguration? { get }
    
}

// MARK: - StructuredCellInvalidatable

public protocol StructuredCellInvalidatable {
    func invalidated()
}
