//
//  FoodDeliveryAPI.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation
import Moya
import ObjectMapper

public enum FoodDeliveryAPI {
    
    static private let clientId: String = "DD20201109000001"
    
    case foodMenu
    case foodPromoMenu
}

extension FoodDeliveryAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://food-delivery.com/v1")!
    }

    public var path: String {
        switch self {
            case .foodMenu: return "/food-menu"
            case .foodPromoMenu: return "/food-promo-menu"
        }
    }

    public var method: Moya.Method {
        switch self {
            case .foodMenu: return .get
            case .foodPromoMenu: return .get
        }
    }
    
    private func jsonFileToData(_ fileName: String) -> Data! {
        do {
            let path = Bundle.main.path(forResource: fileName, ofType: "json")
            let nsdata: NSData = try NSData(contentsOfFile: path!)
            let data: Data = Data(referencing: nsdata)
            return data
        }
        catch let error {
            print(error)
            return nil
        }
    }

    public var sampleData: Data {
        switch self {
            case .foodMenu:
                return jsonFileToData("MockedFoodItems")
            
            case .foodPromoMenu:
                return jsonFileToData("MockedFoodPromoItems")
        }
    }

    public var task: Task {
        let timestamp = "\(Date().timeIntervalSince1970)"
        let authParams = ["clientId": FoodDeliveryAPI.clientId, "timestamp": timestamp]

        switch self {
            case .foodMenu:
                var fmParams = authParams
                fmParams["orderBy"] = "newArrival"
                fmParams["timeRange"] = "pastYear"
                fmParams["limit"] = "1000"
                
                return .requestParameters(parameters: fmParams,
                                          encoding: URLEncoding.default)
            case .foodPromoMenu:
                var fpmParams = authParams
                fpmParams["orderBy"] = "newArrival"
                fpmParams["timeRange"] = "pastWeek"
                fpmParams["limit"] = "200"
                
                return .requestParameters(parameters: fpmParams,
                                          encoding: URLEncoding.default)
        }
    }

    public var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    public var validationType: ValidationType {
        return .successCodes
    }
}
