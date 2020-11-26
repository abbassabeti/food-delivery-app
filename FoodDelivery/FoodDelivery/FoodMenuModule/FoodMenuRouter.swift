//
//  FoodMenuRouter.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation
import UIKit

class FoodMenuRouter: PresenterToRouterFoodMenuProtocol {
    
    // MARK: Static methods
    static func createFoodMenuModule() -> FoodMenuViewController {
        
        let view = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "FoodMenuViewController") as! FoodMenuViewController
        
        var presenter: ViewToPresenterFoodMenuProtocol & InteractorToPresenterFoodMenuProtocol = FoodMenuPresenter()
        var interactor: PresenterToInteractorFoodMenuProtocol = FoodMenuInteractor()
        let router: PresenterToRouterFoodMenuProtocol = FoodMenuRouter()
        
        view.foodMenuPresenter = presenter
            presenter.view = view
            presenter.router = router
            presenter.interactor = interactor
                interactor.presenter = presenter
        
        return view
    }
    
}
