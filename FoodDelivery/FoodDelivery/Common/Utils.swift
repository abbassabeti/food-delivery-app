//
//  Utils.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import Foundation

func printLog(_ msg: String) -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MMM-yy HH:mm:ss.SSSS"
    return (formatter.string(from: date) + " => "  + msg)
}
