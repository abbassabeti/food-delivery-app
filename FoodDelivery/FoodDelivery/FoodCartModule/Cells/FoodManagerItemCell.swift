//
//  FoodManagerItemCell.swift
//  FoodDelivery
//
//  Created by Abbas on 11/27/20.
//
//

import UIKit

class FoodManagerItemCell : UICollectionViewCell {
    static let Identifier = "FoodManagerItemCell"
    
    @IBOutlet private var titleLbl: UILabel!
    
    func setValue(_ item: String) {
        titleLbl.text = item
    }
    
    func updateAsSelectedUI() {
        titleLbl.textColor = isSelected ? .black : .lightGray
    }
}


