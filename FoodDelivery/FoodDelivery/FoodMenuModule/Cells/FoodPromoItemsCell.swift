//
//  FoodPromoItemCell.swift
//  FoodDelivery
//
//  Created by Abbas on 11/27/20.
//
//

import UIKit

class FoodPromoItemsCell : UICollectionViewCell {
    static let Identifier = "FoodPromoItemsCell"
    
    @IBOutlet private var foodPromoImgView: UIImageView!
    @IBOutlet private var foodPromoNameLbl: UILabel!
    
    func setValues(_ foodItem: FoodItem) {
        //foodPromoNameLbl.text = foodItem.name
        foodPromoImgView.image = UIImage(named: foodItem.imageName ?? "")
    }
}

