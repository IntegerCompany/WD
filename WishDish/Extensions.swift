//
//  Extensions.swift
//  WishDish
//
//  Created by Max Vitruk on 12.10.15.
//  Copyright © 2015 integer. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedVIew: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
}

class RoundedBlur: UIVisualEffectView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
}

extension UIImageView {
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
        contentMode = mode
        if let url = NSURL(string: link) {
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, error) -> Void in
                guard let data = data where error == nil else { return }
                dispatch_async(dispatch_get_main_queue()) { () -> Void in self.image = UIImage(data: data)}
            }).resume()
        }
    }
}
