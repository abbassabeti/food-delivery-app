//
//  FDNetworkManager.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation
import Moya
import Alamofire

class FDMoyaProvider : MoyaProvider<FoodDeliveryAPI> {
    init() {
        // mock successful response with 1 sec delay..
        super.init(stubClosure: MoyaProvider.delayedStub(1), session: FDMoyaProvider.defaultSession())
        
        //super.init(stubClosure: MoyaProvider.immediatelyStub, session: FDMoyaProvider.defaultSession())
    }

    fileprivate static func defaultSession() -> Alamofire.Session {
        let config = URLSessionConfiguration.default;
        config.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        config.requestCachePolicy = .useProtocolCachePolicy
        
        return Alamofire.Session(configuration: config)
    }
}
