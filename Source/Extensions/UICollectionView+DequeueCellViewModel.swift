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
        let indetifier = model.reuseIdentifier(for: .collectionView)
        let cell = self.dequeueReusableCell(withReuseIdentifier: indetifier, for: indexPath)
        model.configureAny(cell: cell)
        return cell
    }
    
    public func registerNibs(with identifiers: [String]) {
        for identifier in identifiers {
            let nib = UINib(nibName: identifier, bundle: nil)
            self.register(nib, forCellWithReuseIdentifier: identifier)
        }
    }
    
}
