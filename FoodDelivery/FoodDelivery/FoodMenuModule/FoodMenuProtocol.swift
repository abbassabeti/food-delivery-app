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
    func onReceivingFoodItemsSuccessResponse()
    func onReceivingFoodItemsFailureResponse(_ error: Error)
    func onNewCategorySelected(isLtoR: Bool)
    func showToast(_ str: String)
}


// MARK: View Input (View -> Presenter)
protocol ViewToPresenterFoodMenuProtocol {
    
    var view: PresenterToViewFoodMenuProtocol? { get set }
    var interactor: PresenterToInteractorFoodMenuProtocol? { get set }
    var router: PresenterToRouterFoodMenuProtocol? { get set }
    
    var viewModel : FoodMenuViewModel { get set }
    
    func startReceivingFoodItems()
    
    func updateDisplayFoodItems(newCategory: Int, previousCategory: Int?)
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
