//
//  TableStructuredViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

extension UICollectionView {

    func dequeueReusableCell(withModel model: StructuredCell, for indexPath: IndexPath) -> UICollectionViewCell {
        let indetifier = String(describing: type(of: model).cellAnyType)
        let cell = self.dequeueReusableCell(withReuseIdentifier: indetifier, for: indexPath)
        model.configureAny(cell: cell)
        return cell
    }
    
    func register(nibModels: [StructuredCell.Type]) {
        for model in nibModels {
            let identifier = String(describing: model.cellAnyType)
            let bundle = Bundle(for: model.cellAnyType)
            let nib = UINib(nibName: identifier, bundle: bundle)
            self.register(nib, forCellWithReuseIdentifier: identifier)
        }
    }
    
    func register(models: [StructuredCell.Type]) {
        for model in models {
            let identifier = String(describing: model.cellAnyType)
            self.register(model.cellAnyType, forCellWithReuseIdentifier: identifier)
        }
    }
}
