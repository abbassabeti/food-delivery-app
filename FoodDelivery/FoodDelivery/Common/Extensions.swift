//
//  Extensions.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//  Copyright © 2020 DinDinn. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    func toast(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: (UIDevice.current.userInterfaceIdiom == .pad) ? .alert : .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("toast ok")
            alert.dismiss(animated: true)
        }))
        
        self.present(alert, animated: true)

        // duration in seconds
        let duration: Double = 2

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
