//
//  Extensions.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
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

extension UIView {
    func setShadow(contentView: UIView? = nil, shadowOpacity: Float = 0.12,
                   shadowRadius: CGFloat = 2,
                   cornerRadius: CGFloat = 10,
                   shadowOffset: CGSize = CGSize(width: 0, height: 4),
                   shadowColor: CGColor = UIColor.black.cgColor,padding: CGFloat = 0) {
        DispatchQueue.main.async {
            let previousContentView = self.viewWithTag(29984)
            let _contentView = contentView ?? previousContentView ?? UIView()
            if (contentView == nil && previousContentView == nil){
                self.addSubview(_contentView)
                _contentView.tag = 29984

                NSLayoutConstraint.activate([
                    _contentView.topAnchor.constraint(equalTo: self.topAnchor,constant: padding),
                    _contentView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: padding * -1),
                    _contentView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: padding),
                    _contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: padding * -1)
                ])
            }
            
            _contentView.layer.cornerRadius = cornerRadius
            _contentView.layer.borderWidth = 1.0
            _contentView.layer.borderColor = UIColor.clear.cgColor
            _contentView.layer.masksToBounds = true
            
            self.layer.shadowColor = shadowColor
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowOpacity = shadowOpacity
            self.layer.masksToBounds = false
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: _contentView.layer.cornerRadius).cgPath
        }
        self.clipsToBounds = false
    }
}
