//
//  BadgeButton.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import UIKit
import RxSwift

class BadgeButton: UIButton {
    var badgeLabel = UILabel()
    
    public var badge: Any? = "" {
        didSet {
            guard let val = badge else {
                badgeLabel.isHidden = true
                self.isUserInteractionEnabled = false
                return
            }
            
            if val is String && (val as! String).count > 0 {
                badgeLabel.isHidden = false
                badgeLabel.text = val as? String
                self.isUserInteractionEnabled = true
            }
            else if val is Int {
                badgeLabel.isHidden = false
                badgeLabel.text = "\(val)"
                self.isUserInteractionEnabled = true
            }
            else {
                badgeLabel.isHidden = true
                self.isUserInteractionEnabled = false
            }
        }
    }
 
    public var badgeBackgroundColor = UIColor.systemGreen {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    public var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    public var badgeFont = UIFont.boldSystemFont(ofSize: 8.0) {
        didSet {
            badgeLabel.font = badgeFont
        }
    }
    
    func refresh() {
        layer.cornerRadius = frame.size.height/2
//        layer.masksToBounds = true // should not..
        
        badgeLabel.textColor = badgeTextColor
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.font = badgeFont
        badgeLabel.textAlignment = .center
        
        let badgeWidth = frame.size.width * 0.35
        badgeLabel.frame = CGRect(x: bounds.size.width - badgeWidth/2 - layer.cornerRadius/2,
                                  y: -badgeWidth/2 + layer.cornerRadius/4,
                                  width: badgeWidth,
                                  height: badgeWidth)
        
        badgeLabel.layer.cornerRadius = badgeLabel.frame.height/2
        badgeLabel.layer.masksToBounds = true
        
        addSubview(badgeLabel)
        
        // glow effect..
        let shadowLayer: CAShapeLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        shadowLayer.fillColor = backgroundColor?.cgColor // UIColor.clear.cgColor  //
        shadowLayer.shadowColor = UIColor.darkGray.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.8)
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.shadowRadius = 10
        layer.insertSublayer(shadowLayer, at: 0)
        
        // bring image front after adding glow..
        bringSubviewToFront(imageView!)
    }
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        refresh()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        refresh()
        //fatalError("init(coder:) has not been implemented")
    }
    
    func animate(_ newValue: String) {
        self.badge = newValue
        
        UIView.transition(with: self.badgeLabel, duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.badgeLabel.layer.borderWidth = 1.0
                            self.badgeLabel.layer.borderColor = UIColor.white.cgColor
                            }, completion: { (_) in
                                self.badgeLabel.layer.borderWidth = 0.0
                                self.badgeLabel.layer.borderColor = UIColor.clear.cgColor
                            })
    }
}

