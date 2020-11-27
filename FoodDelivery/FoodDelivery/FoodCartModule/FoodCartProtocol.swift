//
//  FoodCartProtocol.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation


// MARK: View Output (Presenter -> View)
protocol PresenterToViewFoodCartProtocol {
   func onRetrieveFoodCartItemsResponse(foodCartTotal: Float,isFoodCartEmpty: Bool)
}


// MARK: View Input (View -> Presenter)
protocol ViewToPresenterFoodCartProtocol {
    
    var view: PresenterToViewFoodCartProtocol? { get set }
    var interactor: PresenterToInteractorFoodCartProtocol? { get set }
    var router: PresenterToRouterFoodCartProtocol? { get set }
    
    var viewModel: FoodCartViewModel { get set }
    
    func startRetrievingFoodCartItems()
}


// MARK: Interactor Input (Presenter -> Interactor)
protocol PresenterToInteractorFoodCartProtocol {

    var presenter: InteractorToPresenterFoodCartProtocol? { get set }
    
    func retrieveFoodCartItems()
}


// MARK: Interactor Output (Interactor -> Presenter)
protocol InteractorToPresenterFoodCartProtocol {

    func onRetrieveFoodCartItems(_ foodItems: [FoodItem])
}


// MARK: Router Input (Presenter -> Router)
protocol PresenterToRouterFoodCartProtocol : class {

    static func createFoodCartModule() -> FoodCartViewController
}
