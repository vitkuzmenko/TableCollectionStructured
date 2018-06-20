//
//  TableStructuredViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

extension UITableView {
    
    func dequeueReusableCell(withModel model: StructuredCell, for indexPath: IndexPath) -> UITableViewCell {
        let indetifier = model.reuseIdentifier(for: .tableView)
        let cell = self.dequeueReusableCell(withIdentifier: indetifier, for: indexPath)
        model.configureAny(cell: cell)
        return cell
    }
    
    public func registerNibs(with identifiers: [String]) {
        for identifier in identifiers {
            let nib = UINib(nibName: identifier, bundle: nil)
            self.register(nib, forCellReuseIdentifier: identifier)
        }
    }
    
}
