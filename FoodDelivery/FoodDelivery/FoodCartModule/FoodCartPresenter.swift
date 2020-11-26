//
//  FoodCartPresenter.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation

class FoodCartPresenter: ViewToPresenterFoodCartProtocol {

    // MARK: Properties
    var view: PresenterToViewFoodCartProtocol?
    var interactor: PresenterToInteractorFoodCartProtocol?
    var router: PresenterToRouterFoodCartProtocol?
    
    func startRetrievingFoodCartItems() {
        interactor?.retrieveFoodCartItems()
    }
}

extension FoodCartPresenter: InteractorToPresenterFoodCartProtocol {
    func onRetrieveFoodCartItems(_ foodItems: [FoodItem]) {
        view?.onRetrieveFoodCartItemsResponse(foodItems)
    }
}
