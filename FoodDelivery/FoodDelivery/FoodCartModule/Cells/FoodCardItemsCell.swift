//
//  FoodCardItemsCell.swift
//  FoodDelivery
//
//  Created by Abbas on 11/27/20.
//
//

import UIKit

class FoodCartItemsCell : UITableViewCell {
    static let Identifier = "FoodCartItemsCell"
    
    @IBOutlet private var foodImgView: UIImageView!
    @IBOutlet private var foodNameLbl: UILabel!
    @IBOutlet private var foodTotalPriceLbl: UILabel!
    @IBOutlet private var foodPriceLbl: UILabel!
    @IBOutlet private var foodQtyLbl: UILabel!
    @IBOutlet var foodRemoveButton: UIButton!
    
    func setValues(_ foodItemSummary: FoodItemSummary) {
        foodImgView.image = UIImage(named: foodItemSummary.foodItem?.imageName ?? "")
        foodImgView.layer.borderWidth = 2
        foodImgView.layer.borderColor = UIColor.lightGray.cgColor
        
        foodNameLbl.text = foodItemSummary.foodItem?.name
        
        foodPriceLbl.text = "\(foodItemSummary.foodItem?.price ?? 0.0) usd"
        
        foodTotalPriceLbl.text = "\(foodItemSummary.totalCost) usd"
        
        foodQtyLbl.text = "qty: \(foodItemSummary.foodItemCount)"
    }
}
