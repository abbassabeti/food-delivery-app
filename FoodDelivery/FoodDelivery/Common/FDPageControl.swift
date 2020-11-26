//
//  FDPageControl.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//  Copyright © 2020 DinDinn. All rights reserved.
//

import UIKit

class FDPageControl : UIPageControl {
    let badgeImgName = "circlebadge.fill"
    var dotsViews: [UIImageView] = []
    
    func setupDots(){
        dotsViews = self.subviews.first?.subviews.first?.subviews as? [UIImageView] ?? []
        dotsViews.forEach({$0.contentMode = .scaleAspectFill})
        self.currentPage = 0
    }
    
    override var numberOfPages: Int {
        didSet{
            setupDots()
        }
    }
    
    override var currentPage: Int{
        didSet{
            adjustDots()
        }
    }
    
    func adjustDots(){
        DispatchQueue.main.async {
            self.dotsViews.forEach {
                $0.transform = CGAffineTransform(scaleX: 1, y: 1)
                let img = UIImage(systemName: self.badgeImgName)
                $0.image = img
            }
            guard self.dotsViews.count > self.currentPage else {return}
            let element = self.dotsViews[self.currentPage]
            let img = UIImage(systemName: self.badgeImgName)?.resized(to: CGSize(width: 12, height: 12))
            element.image = img
            self.dotsViews[self.currentPage].setNeedsLayout()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
}
