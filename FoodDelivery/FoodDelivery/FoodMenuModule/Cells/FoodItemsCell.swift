//
//  FoodItemsCell.swift
//  FoodDelivery
//
//  Created by Abbas on 11/27/20.
//
//

import UIKit
import RxSwift

class FoodItemsCell : UITableViewCell {
    static let Identifier = "FoodItemsCell"
    
    @IBOutlet private var foodImgView: UIImageView!
    @IBOutlet private var foodNameLbl: UILabel!
    @IBOutlet private var foodIngredientsLbl: UILabel!
    @IBOutlet private var foodDimensionsLbl: UILabel!
    @IBOutlet var foodAddButton: UIButton!
    @IBOutlet weak var foodItemCellView: UIView!
    
    var disposeBagOfCell = DisposeBag()
    
    // Make disposbag empty for reusing cell.
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBagOfCell = DisposeBag()
        setShadow()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setShadow()
    }
    
    func setShadow(){
        let shadowView : UIView = self.foodItemCellView
        shadowView.setShadow(contentView: self.contentView, shadowOpacity: 0.05, shadowRadius: 8, cornerRadius: 8, shadowOffset: CGSize(width: 1, height: 3))
    }
    
    func setValues(_ foodItem: FoodItem) {
        foodImgView.image = UIImage(named: foodItem.imageName ?? "")
        
        let roundCornerView = foodImgView.superview!
        roundCornerView.layer.cornerRadius = 20
        roundCornerView.layer.masksToBounds = true
        
        roundCornerView.layer.borderWidth = 0.1
        roundCornerView.layer.borderColor = UIColor.lightGray.cgColor
        
        foodNameLbl.text = foodItem.name
        foodIngredientsLbl.text = foodItem.ingredients
        foodDimensionsLbl.text = "\(foodItem.weight ?? "0") grams, \(foodItem.size ?? "0") cm"
        
        foodAddButton.setTitle("\(foodItem.price ?? 0.0) usd", for: .normal)
        foodAddButton.layer.cornerRadius = foodAddButton.frame.size.height/2
        foodAddButton.layer.masksToBounds = true
    }
}

