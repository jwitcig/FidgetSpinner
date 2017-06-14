//
//  Spinner.swift
//  FidgetSpinner
//
//  Created by Developer on 6/7/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import SpriteKit
import UIKit

struct Spinner {
    let name: String
    
    let bodyStyle: Int
    let bearingStyle: Int
    let capStyle: Int
    let bodyColor: UIColor
    let bearingColor: UIColor
    let capColor: UIColor
    
    init(name: String) {
        self.name = name
        
        self.bodyStyle = 0
        self.bearingStyle = 0
        self.capStyle = 0
        self.bodyColor = ColorPickerStyleKit.color0
        self.bearingColor = ColorPickerStyleKit.color0
        self.capColor = ColorPickerStyleKit.color0
    }
    
    init?(dictionary: [String : Any]) {
        self.name = dictionary["name"]! as! String
        
        self.bodyStyle = dictionary["bodyStyle"]! as! Int
        self.bearingStyle = dictionary["bodyStyle"]! as! Int
        self.capStyle = dictionary["bodyStyle"]! as! Int
        
        self.bodyColor = UIColor(ciColor: CIColor(string: dictionary["bodyColor"]! as! String))
        self.bearingColor = UIColor(ciColor: CIColor(string: dictionary["bearingColor"]! as! String))
        self.capColor = UIColor(ciColor: CIColor(string: dictionary["capColor"]! as! String))
    }
    
    func imageOfSpinner() -> UIImage {
        let imageSize = CGSize(width: 104, height: 104)
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        BearingStyles.draw(body: bearingStyle,
                           rect: CGRect(origin: .zero, size: imageSize),
                           resizing: .aspectFit,
                           bodyColor: bearingColor)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        CapStyles.draw(body: capStyle,
                       rect: CGRect(origin: .zero, size: imageSize),
                       resizing: .aspectFit,
                       bodyColor: capColor)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        let spinnerSize = CGSize(width: 360, height: 328)
        
        UIGraphicsBeginImageContextWithOptions(spinnerSize, false, 0)
        BodyStyles.draw(body: bodyStyle,
                        rect: CGRect(origin: .zero, size: spinnerSize),
                        resizing: .aspectFit,
                        bodyColor: bodyColor,
                        image: image ?? UIImage())
        
        let spinnerImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return spinnerImage
    }
}

