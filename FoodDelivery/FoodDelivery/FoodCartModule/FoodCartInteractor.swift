//
//  FoodCartInteractor.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation

class FoodCartInteractor: PresenterToInteractorFoodCartProtocol {

    // MARK: Properties
    var presenter: InteractorToPresenterFoodCartProtocol?
    
    func retrieveFoodCartItems() {
        presenter?.onRetrieveFoodCartItems(FoodCart.sharedCart.foodItems.value)
    }
}
