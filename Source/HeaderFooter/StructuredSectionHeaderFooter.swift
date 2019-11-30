//
//  StructuredSectionHeaderFooter.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 30.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

// MARK: - StructuredSectionHeaderFooter

public protocol StructuredSectionHeaderFooter {
    
    static func reuseIdentifier(for parentView: StructuredView) -> String
    
    func configureAny(view: UIView)
    
}

// MARK: - StructuredTableSectionHeaderFooter

public protocol StructuredTableSectionHeaderFooter: StructuredSectionHeaderFooter {
    
    associatedtype TableViewHeaderFooterType: UITableViewHeaderFooterView
    
    static func reuseIdentifierForTableViewHeaderFooter() -> String
    
    func configure(tableViewHeaderFooterView view: TableViewHeaderFooterType)
    
}

public extension StructuredTableSectionHeaderFooter {
    
    static func reuseIdentifier(for parentView: StructuredView) -> String {
        switch parentView {
        case .tableView:
            return reuseIdentifierForTableViewHeaderFooter()
        default:
            fatalError()
        }
    }
    
    func configureAny(view: UIView) {
        if let view = view as? TableViewHeaderFooterType {
            configure(tableViewHeaderFooterView: view)
        } else {
            assertionFailure("StructuredTableViewCell: cell should be subclass of UITableViewCell")
        }
    }
    
}

// MARK: - StructuredTableSectionHeaderFooterDynamicHeight

public protocol StructuredTableSectionHeaderFooterDynamicHeight {
    
    func height(for parentView: UITableView) -> CGFloat
    
}
