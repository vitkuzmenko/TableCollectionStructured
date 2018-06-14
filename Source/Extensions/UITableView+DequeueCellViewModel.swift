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
        let indetifier = String(describing: type(of: model).cellAnyType).components(separatedBy: ".").last!
        let cell = self.dequeueReusableCell(withIdentifier: indetifier, for: indexPath)
        model.configureAny(cell: cell)
        return cell
    }
    
    func register(nibModels: [StructuredCell.Type]) {
        for model in nibModels {
            let identifier = String(describing: model.cellAnyType).components(separatedBy: ".").last!
            let bundle = Bundle.main
            let nib = UINib(nibName: identifier, bundle: bundle)
            self.register(nib, forCellReuseIdentifier: identifier)
        }
    }
    
}
