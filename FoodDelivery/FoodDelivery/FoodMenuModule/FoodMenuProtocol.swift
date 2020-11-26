//
//  FoodMenuProtocol.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation


// MARK: View Output (Presenter -> View)
protocol PresenterToViewFoodMenuProtocol {
    func onReceivingFoodItemsSuccessResponse(_ foodItems: [FoodItem], _ foodPromoItems: [FoodItem])
    func onReceivingFoodItemsFailureResponse(_ error: Error)
}


// MARK: View Input (View -> Presenter)
protocol ViewToPresenterFoodMenuProtocol {
    
    var view: PresenterToViewFoodMenuProtocol? { get set }
    var interactor: PresenterToInteractorFoodMenuProtocol? { get set }
    var router: PresenterToRouterFoodMenuProtocol? { get set }
    
    func startReceivingFoodItems()
}


// MARK: Interactor Input (Presenter -> Interactor)
protocol PresenterToInteractorFoodMenuProtocol {
    
    var presenter: InteractorToPresenterFoodMenuProtocol? { get set }
    
    func retrieveFoodItems()
}


// MARK: Interactor Output (Interactor -> Presenter)
protocol InteractorToPresenterFoodMenuProtocol {
    func onReceivingFoodItemsSuccess(_ foodItems: [FoodItem], _ foodPromoItems: [FoodItem])
    func onReceivingFoodItemsFailure(_ error: Error)
}


// MARK: Router Input (Presenter -> Router)
protocol PresenterToRouterFoodMenuProtocol {
    static func createFoodMenuModule() -> FoodMenuViewController
}
