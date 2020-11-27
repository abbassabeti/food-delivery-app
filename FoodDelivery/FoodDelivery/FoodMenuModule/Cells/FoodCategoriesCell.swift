//
//  FoodCategoriesCell.swift
//  FoodDelivery
//
//  Created by Abbas on 11/27/20.
//
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
