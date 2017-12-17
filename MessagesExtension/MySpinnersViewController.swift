//
//  MySpinnersViewController.swift
//  FidgetSpinner
//
//  Created by Developer on 6/6/17.
//  Copyright © 2017 JwitApps. All rights reserved.
//

import UIKit

import Cartography

import iMessageTools

class MySpinnersViewController: UIViewController {

    var orientationManager: OrientationManager!
    
    var spinners: [Spinner] = []
    
    var onSelection: ((Spinner)->())!
    
    init(orientationManager: OrientationManager, onSelection: @escaping (Spinner)->()) {
        self.onSelection = onSelection
        self.orientationManager = orientationManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topView = PaintCodeView {
            LogoStyleKit.drawViewBanner(frame: $0, resizing: .aspectFit)
        }
        
        view.addSubview(topView)
        
        let swipeToPlay = PaintCodeView {
             UserInterfaceStyleKit.drawSwipeToPlay(frame: $0, resizing: .stretch)
        }
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(MySpinnersViewController.swipedUp(recognizer:)))
        swipeUp.direction = .up
        
        swipeToPlay.addGestureRecognizer(swipeUp)
        
        view.addSubview(swipeToPlay)
        constrain(topView, swipeToPlay, view) {
            $0.leading == $2.leading
            $0.trailing == $2.trailing
            $0.top == $2.top
            $0.width == $0.height * 1183/182.0
            
            $1.leading == $2.leading
            $1.trailing == $2.trailing
            $1.top == $0.bottom
            $1.bottom == $2.bottom
        }
    }
    
    func swipedUp(recognizer: UISwipeGestureRecognizer) {
        orientationManager.requestPresentationStyle(.expanded)
        onSelection(Spinner(name: "asdf"))
    }
}
