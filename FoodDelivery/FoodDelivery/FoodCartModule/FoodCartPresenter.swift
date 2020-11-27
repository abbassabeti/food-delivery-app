//
//  FoodCartPresenter.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation
import RxSwift
import RxCocoa

class FoodCartPresenter: ViewToPresenterFoodCartProtocol {

    // MARK: Properties
    var view: PresenterToViewFoodCartProtocol?
    var interactor: PresenterToInteractorFoodCartProtocol?
    var router: PresenterToRouterFoodCartProtocol?
    
    var viewModel: FoodCartViewModel = FoodCartViewModel()
    
    func startRetrievingFoodCartItems() {
        interactor?.retrieveFoodCartItems()
    }
}

extension FoodCartPresenter: InteractorToPresenterFoodCartProtocol {
    func onRetrieveFoodCartItems(_ foodItems: [FoodItem]) {
        self.viewModel.foodCartItemsRelay.accept(self.viewModel.toSummary(foodItems))
        view?.onRetrieveFoodCartItemsResponse(foodCartTotal: self.viewModel.foodCartTotal,isFoodCartEmpty: self.viewModel.isFoodCartEmpty)
    }
}


class FoodCartViewModel {
    var foodManagerItems = Observable.just(["Cart", "Orders", "Info"])
    var foodCartItemsRelay: BehaviorRelay<[FoodItemSummary]> = BehaviorRelay(value: [])
    var isFoodCartEmpty: Bool {
        foodCartItemsRelay.value.count == 0
    }
    
    var foodCartTotal: Float {
        return foodCartItemsRelay.value.map( {$0.totalCost} ).reduce(0, +)
    }
    
    func toSummary(_ foodItems: [FoodItem]) -> [FoodItemSummary] {
        guard foodItems.count > 0 else {
            return [FoodItemSummary]()
        }
      
        // set of food items...
        let foodItemsSet = Set<FoodItem>(foodItems)
      
        // count of each food item..
        let foodItemsSummary:[FoodItemSummary] = foodItemsSet.map { foodItem in
            let count: Int = foodItems.reduce(0) {
                cummTotal, reduceFoodItem in

                if foodItem == reduceFoodItem {
                    return cummTotal + 1
                }

                return cummTotal
            }

            var fiSummary: FoodItemSummary = FoodItemSummary()
            fiSummary.foodItem = foodItem
            fiSummary.foodItemCount = count
            fiSummary.totalCost = Float(count) * (foodItem.price ?? 0.0)

            return fiSummary
        }

        return foodItemsSummary
    }
}
