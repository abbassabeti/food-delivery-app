//
//  FoodItem.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation
import RxCocoa
import ObjectMapper

struct FoodItem: Mappable, Hashable {
    var itemId: String?
    var name: String?
    var imageName: String?
    var ingredients: String?
    var weight: String?
    var size: String?
    var price: Float?
    
    init?() {}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        itemId      <- map["itemId"]
        name        <- map["name"]
        imageName   <- map["imageName"]
        ingredients <- map["ingredients"]
        weight      <- map["weight"]
        size        <- map["size"]
        price       <- map["price"]
    }
    
    static let mockedFoodPromoItems: [FoodItem] = {
        let mockedFoodPromoMenuItems = Mapper<FoodItem>().mapArray(JSONfile: "MockedFoodPromoItems.json")
        return mockedFoodPromoMenuItems!
    } ()
}

class FoodCart {
    static let sharedCart = FoodCart()
    var foodItems: BehaviorRelay<[FoodItem]> = BehaviorRelay(value: [])
    
    func add(_ foodItem: FoodItem) {
        let newValue = foodItems.value + [foodItem]
        foodItems.accept(newValue)
    }
}
