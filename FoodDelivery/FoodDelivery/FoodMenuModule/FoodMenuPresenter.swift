//
//  FoodMenuPresenter.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation
import RxSwift
import RxCocoa

class FoodMenuPresenter: ViewToPresenterFoodMenuProtocol {

    // MARK: Properties
    var view: PresenterToViewFoodMenuProtocol?
    var interactor: PresenterToInteractorFoodMenuProtocol?
    var router: PresenterToRouterFoodMenuProtocol?
    
    var viewModel : FoodMenuViewModel = FoodMenuViewModel()
    
    func startReceivingFoodItems() {
        interactor?.retrieveFoodItems()
    }
    
    func updateDisplayFoodItems(newCategory: Int, previousCategory: Int? = nil) {
        let isLtoR : Bool = newCategory < (previousCategory ?? 0)
        
        switch newCategory {
            case 0:
                self.viewModel.displayFoodItemsRelay.accept(self.viewModel.foodItemsSource.filter { $0.type == 1 })
            case 1:
                self.viewModel.displayFoodItemsRelay.accept(self.viewModel.foodItemsSource.filter { $0.type == 2 })
            case 2:
                self.viewModel.displayFoodItemsRelay.accept(self.viewModel.foodItemsSource.filter { $0.type == 3 })
            default:
                print("popup")
                // assumed category index within the range :)
                self.view?.toast("\(self.viewModel.foodCategoriesSource[newCategory]) Coming Soon..")
        }
        
        
        //TODO Action of update moved to pTov method
    }
}

extension FoodMenuPresenter: InteractorToPresenterFoodMenuProtocol {
    
    func onReceivingFoodItemsSuccess(_ foodItems: [FoodItem], _ foodPromoItems: [FoodItem]) {
        self.viewModel.foodItemsSource = foodItems
        self.viewModel.foodPromoItemsSource = foodPromoItems
        view?.onReceivingFoodItemsSuccessResponse()
    }
    
    func onReceivingFoodItemsFailure(_ error: Error) {
        view?.onReceivingFoodItemsFailureResponse(error)
    }
}

class FoodMenuViewModel {
    
    var displayFoodPromoItemsRelay: BehaviorRelay<[FoodItem]> = BehaviorRelay(value: [])
    var foodPromoItemsSource: [FoodItem] = [FoodItem](){
        didSet{
            displayFoodPromoItemsRelay.accept(foodPromoItemsSource)
        }
    }

    var foodCategoriesSource: [String] = ["Pizza", "Sushi", "Drinks"]
    
    var displayFoodItemsRelay: BehaviorRelay<[FoodItem]> = BehaviorRelay(value: [])
    var foodItemsSource: [FoodItem] = [FoodItem](){
        didSet{
            displayFoodItemsRelay.accept(foodItemsSource)
        }
    }
    
}
