//
//  Extensions.swift
//  FidgetSpinner
//
//  Created by Developer on 5/31/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import UIKit

public extension CGPoint {
    public func angle(toPoint point: CGPoint) -> CGFloat {
        let origin = CGPoint(x: point.x - self.x, y: point.y - self.y)
        let radians = CGFloat(atan2f(Float(origin.y), Float(origin.x)))
        let corrected = radians < 0 ? radians + 2 * .pi : radians
        return corrected
    }
    
    public func distance(toPoint point: CGPoint) -> CGFloat {
        return sqrt( pow(self.x-point.x, 2) + pow(self.y - point.y, 2) )
    }
}

public extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}
