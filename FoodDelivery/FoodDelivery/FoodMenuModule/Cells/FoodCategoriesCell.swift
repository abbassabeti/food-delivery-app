//
//  FoodCategoriesCell.swift
//  FoodDelivery
//
//  Created by Abbas on 11/27/20.
//  Copyright © 2020 DinDinn. All rights reserved.
//

import UIKit

class FoodCategoriesCell : UICollectionViewCell {
    static let Identifier = "FoodCategoriesCell"
    
    @IBOutlet private var foodCategoryLbl: UILabel!
    
    func setValue(_ category: String) {
        foodCategoryLbl.text = category
    }
    
    func updateAsSelectedUI() {
        foodCategoryLbl.textColor = isSelected ? .black : .lightGray
    }
}
