//
//  CountryHeaderView.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 30.11.2019.
//  Copyright © 2019 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

struct CountryHeaderViewModel {

    let image: UIImage?
    
    let title: String
    
    let count: String
    
    init(country: Country) {
        self.image = UIImage(named: country.title)
        self.title = country.title
        self.count = String(country.cities.count)
    }
    
}

extension CountryHeaderViewModel: StructuredTableSectionHeaderFooter {
    
    static func reuseIdentifierForTableViewHeaderFooter() -> String {
        return "CountryHeaderView"
    }
    
    func configure(tableViewHeaderFooterView view: CountryHeaderView) {
        view.imageView.image = image
        view.titleLabel.text = title
        view.countLabel.text = count
    }
    
}

extension CountryHeaderViewModel: StructuredTableSectionHeaderFooterDynamicHeight {
    
    func height(for parentView: UITableView) -> CGFloat {
        return 42
    }
    
}
