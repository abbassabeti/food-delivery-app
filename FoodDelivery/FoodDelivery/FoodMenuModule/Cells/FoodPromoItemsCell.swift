//
//  FoodPromoItemCell.swift
//  FoodDelivery
//
//  Created by Abbas on 11/27/20.
//  Copyright © 2020 DinDinn. All rights reserved.
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

