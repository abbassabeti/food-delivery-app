//
//  FoodMenuInteractor.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import ObjectMapper

class FoodMenuInteractor: PresenterToInteractorFoodMenuProtocol {

    // MARK: Properties
    var presenter: InteractorToPresenterFoodMenuProtocol?
    
    let fdNetworkMgr = FDMoyaProvider()
    let disposeBag = DisposeBag()
    
    func retrieveFoodItems() {
        let foodMenuRequest = fdNetworkMgr.rx.request(.foodMenu)
        let foodPromoMenuRequest = fdNetworkMgr.rx.request(.foodPromoMenu)
        
        Observable.zip(foodMenuRequest.mapJSON().asObservable(), foodPromoMenuRequest.mapJSON().asObservable()) {
            return ($0, $1)
        }
        .subscribe( onNext: { foodMenuResult, foodPromoMenuResult in
            let foodItems = Mapper<FoodItem>().mapArray(JSONObject: foodMenuResult) ?? [FoodItem]()
            let foodPromoItems = Mapper<FoodItem>().mapArray(JSONObject: foodPromoMenuResult) ?? [FoodItem]()
            
            self.presenter?.onReceivingFoodItemsSuccess(foodItems, foodPromoItems)
        }, onError: { error in
            self.presenter?.onReceivingFoodItemsFailure(error)
        }).disposed(by: disposeBag)
    }
}
