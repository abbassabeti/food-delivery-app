//
//  FoodMenuPresenter.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation

class FoodMenuPresenter: ViewToPresenterFoodMenuProtocol {

    // MARK: Properties
    var view: PresenterToViewFoodMenuProtocol?
    var interactor: PresenterToInteractorFoodMenuProtocol?
    var router: PresenterToRouterFoodMenuProtocol?
    
    func startReceivingFoodItems() {
        interactor?.retrieveFoodItems()
    }
}

extension FoodMenuPresenter: InteractorToPresenterFoodMenuProtocol {
    
    func onReceivingFoodItemsSuccess(_ foodItems: [FoodItem], _ foodPromoItems: [FoodItem]) {
        view?.onReceivingFoodItemsSuccessResponse(foodItems, foodPromoItems)
    }
    
    func onReceivingFoodItemsFailure(_ error: Error) {
        view?.onReceivingFoodItemsFailureResponse(error)
    }
}
